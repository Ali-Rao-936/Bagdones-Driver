# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Zaytoon rider/driver app (`zaytoon_rider`) — a Flutter app for delivery drivers. Talks to
`https://api.zaytoon.xyz/api/v1.0`. Platforms generated: android, ios, web.

Phase 0 scaffold: the plumbing (auth, networking, routing, storage) is real and works
end-to-end; the UI is deliberately minimal. Per README, still TODO — Live tab polling +
new-order detection, paginated History, Settings (profile/language/help), Order Details
screen, and real visual design for Login.

## Commands

```bash
flutter pub get                                  # after any pubspec change
flutter analyze                                  # lint + type check; keep at "No issues found!"
flutter test                                     # full suite
flutter test test/features/auth/login_screen_test.dart          # single file
flutter test --plain-name 'validates both fields when Log in is pressed'   # single test
flutter run -d <device-id>                       # flutter devices to list ids
```

## Architecture

Layered feature-first: `lib/core/` holds cross-cutting infrastructure, `lib/features/<feature>/`
splits into `data/` (repositories), `domain/` (models), `presentation/` (providers + screens).

**State is Riverpod, hand-written — no `@riverpod` codegen.** Providers are declared manually
with `NotifierProvider`/`Provider`. Keep it that way unless the codegen migration is done
wholesale.

### The auth session is the app's spine

`AuthNotifier` (`features/auth/presentation/providers/auth_provider.dart`) owns session state as
an `AuthState { status, driver, errorMessage }` with `AuthStatus { unknown, authenticated,
unauthenticated }`. It self-bootstraps in `build()`: reads the stored token, calls `/delivery/me`,
and resolves `unknown` → authenticated/unauthenticated. `unknown` means "still deciding" — routing
must wait it out, not treat it as logged-out.

### Routing reacts to auth *status*, not auth state

`appRouterProvider` (`core/router/app_router.dart`) builds **one** `GoRouter` that stays alive for
the app's lifetime. It must not `ref.watch(authProvider)` in the provider body — that rebuilds the
router on every `AuthState` change (including merely setting `errorMessage`), tearing down the
navigation tree along with each screen's `State` and `TextEditingController`s, so typed text is
lost and in-flight `setState` calls are swallowed.

Instead, a private `ChangeNotifier` bridges the two: it `ref.listen`s to `authProvider` and only
calls `notifyListeners()` when `status` actually changes, wired in as GoRouter's
`refreshListenable`. `redirect` then does its own `ref.read(authProvider)` each time GoRouter
re-evaluates. Preserve this arrangement when touching routing.

### ApiClient knows nothing about Riverpod

`core/network/api_client.dart` is a Dio wrapper that takes `getToken`, `getLocale`, and
`onUnauthorized` as **callbacks**, deliberately so it has zero dependency on Riverpod or any
feature and stays independently testable. Don't import providers into it.

Its interceptors attach `Authorization: Bearer <token>` and `Accept-Language` (backend returns
localized content), and route 401s to `onUnauthorized` — which clears the token and flips auth to
unauthenticated, so an expired session bounces to Login from anywhere.

A `_DebugLogInterceptor` registered under `if (kDebugMode)` logs requests/responses/errors with
timings. It redacts `Authorization`, `password`, and `token` values and truncates bodies at 1000
chars — keep both properties if extending it.

### Errors: ApiException vs everything else

`_mapError` turns `DioException`s into a sealed `ApiException` hierarchy (`Unauthorized`,
`Forbidden`, `Validation`, `Network`, `Unknown`) carrying the backend's own `message` where there
is one, so UI can display `e.message` directly without knowing about HTTP.

Note the trap this codebase already hit: a **2xx whose JSON shape doesn't match the casts** in
`AuthRepository`/`Driver.fromJson` throws a `TypeError`, not an `ApiException`. `AuthNotifier.login`
therefore catches both — `on ApiException` (surface the message) and bare `catch` (log it, report
"unexpected response") — and `LoginScreen` reads `authProvider`'s `errorMessage` rather than
inventing its own text. Don't collapse these back into one generic "login failed" message.

### Form validation convention

`LoginScreen` keeps a `_autovalidate` bool: the `Form` is `AutovalidateMode.disabled` until the
submit button is pressed once, then switches to `onUserInteraction`. This is intentional — validate
nothing before the user has tried to submit, then validate each field independently as it's edited.
Reuse this pattern for new forms.

## Conventions

- Locale is `en`/`ar` only (`localeProvider`), in-memory for now; persisting it is Settings-tab work.
- Tokens go through `SecureStorageService`, never `FlutterSecureStorage` directly.
- Environment values live in `core/env/env_config.dart`. Only production exists; when staging
  arrives, switch on `--dart-define=ENV=staging` rather than hardcoding.
- Widget tests should pump the screen directly, not `ZaytoonRiderApp` — the full app instantiates
  `AuthNotifier` → `SecureStorageService`, which hits a platform channel that doesn't exist in tests.
