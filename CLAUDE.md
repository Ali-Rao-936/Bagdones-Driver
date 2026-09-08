# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Zaytoon rider/driver app (`zaytoon_rider`) — a Flutter app for delivery drivers. Talks to
`https://api.zaytoon.xyz/api/v1.0`. Platforms generated: android, ios, web.

Working end to end: auth, networking, routing, secure storage, splash, the Settings tab
with its four sub-screens, the History tab against real order data, and Firebase Cloud
Messaging on both platforms. Still TODO — the Live tab (order polling + new-order
detection), the Order Details screen, sending the FCM token to the backend (no endpoint
yet), and real visual design for Login.

**App identifiers differ per platform, deliberately.** Android is `com.bagdones.delivery`;
iOS is `com.bagdones.d`. The original iOS bundle ID is permanently registered to a
different Apple team, so iOS was moved rather than renaming Android. Firebase holds them
as two separate app registrations in project `bagdones-e-c-bv`. Don't "fix" the mismatch.

## Commands

```bash
flutter pub get                                  # after any pubspec change
flutter analyze                                  # lint + type check; keep at "No issues found!"
flutter test                                     # full suite
flutter test test/features/auth/login_screen_test.dart          # single file
flutter test --plain-name 'validates both fields when Log in is pressed'   # single test
flutter run -d <device-id>                       # flutter devices to list ids
flutter build apk --debug                        # Android compile check
flutter build ios --debug                        # iOS compile + signing check
```

`flutter analyze` does not compile Kotlin or Swift, so a native-side break (an Android
namespace/package mismatch, a bad entitlement) only shows up in the platform builds above.

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

### One ApiClient for the whole app

`apiClientProvider` (`core/network/api_client_provider.dart`) owns the single [ApiClient].
`AuthRepository` and `OrdersRepository` both take it via `ref.read` rather than each
constructing their own Dio — one place handling the auth header, `Accept-Language`, and
global 401s.

Note the deliberate near-cycle: `authProvider.build()` reads `apiClientProvider`, whose
`onUnauthorized` callback reads `authProvider.notifier` back. This is safe *because the
callback only resolves at 401 time*, long after both providers exist. Don't hoist that
`ref.read` out of the closure — doing so creates a real circular dependency.

`AuthNotifier.forceLogout()` exists for exactly that callback: the provider clears the
token itself, so `forceLogout` only resets state.

### Response envelopes

The backend wraps everything as `{errors, data, message, code}`. `ApiClient.unwrap()` strips
the outer `data`, but **inner shapes still vary per endpoint** and are the single most
common source of bugs here:

- `/delivery/me` → `data.delivery_man` (an object)
- `/delivery/auth/login` → `data.delivery_man` + `data.token`
- `/delivery/orders` → `data.data` (the array) + `data.pagination`, whose last-page key is
  **`total_pages`**, not `last_page`

Reading paging off the wrong level yields nulls that collapse `hasMore` to `1 < 1 == false`,
which silently kills infinite scroll rather than erroring. Always confirm a new endpoint's
real shape from the debug interceptor's logged body before writing `fromJson`.

Also note `unwrap()` casts the unwrapped value to `Map<String, dynamic>` — an endpoint
returning a bare list under `data` will throw.

### Errors: ApiException vs everything else

`_mapError` turns `DioException`s into a sealed `ApiException` hierarchy (`Unauthorized`,
`Forbidden`, `Validation`, `Network`, `Unknown`) carrying the backend's own `message` where there
is one, so UI can display `e.message` directly without knowing about HTTP.

Note the trap this codebase already hit: a **2xx whose JSON shape doesn't match the casts** in
`AuthRepository`/`Driver.fromJson` throws a `TypeError`, not an `ApiException`. `AuthNotifier.login`
therefore catches both — `on ApiException` (surface the message) and bare `catch` (log it, report
"unexpected response") — and `LoginScreen` reads `authProvider`'s `errorMessage` rather than
inventing its own text. Don't collapse these back into one generic "login failed" message.

### Push notifications (FCM)

`core/notifications/push_service.dart` wraps `FirebaseMessaging` so nothing else imports it
directly. Three things in it are load-bearing and easy to break:

1. **`firebaseMessagingBackgroundHandler` is top-level with `@pragma('vm:entry-point')`** and
   calls `Firebase.initializeApp()` itself. The OS runs it in a *fresh isolate* where nothing
   from the running app exists. It cannot become a method or closure.
2. **Apple platforms must wait for the APNs token.** iOS delivers it asynchronously after
   `requestPermission()` returns, and `getToken()` throws `apns-token-not-set` if called
   first. `_awaitApnsToken()` polls for it. The wait is gated to iOS/macOS —
   `getAPNSToken()` always returns null on Android, so running it there would stall and
   then skip the token entirely.
3. **`setForegroundNotificationPresentationOptions`** is what makes iOS show a banner while
   the app is foregrounded. Android ignores it: a foreground push there fires `onMessage`
   with no visible notification, which is correct, not a bug. Showing one would need
   `flutter_local_notifications`.

`main()` awaits `Firebase.initializeApp()` *before* `runApp()`, so a Firebase failure means
no UI renders at all. Bear that in mind when debugging a white screen.

The Dart background handler only runs for messages carrying a `data` payload (iOS also needs
`content-available`). A notification-only test from the Firebase console shows a banner
without ever waking the isolate — expected, not a failure.

The FCM token is currently only logged; there's no backend endpoint to register it against.
Note `onTokenRefresh` also fires once on subscription with the current token, so whatever
eventually posts it should dedupe.

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
- Settings sub-screens use plain `Navigator.push`, not go_router routes. They sit on top of a tab
  inside `HomeShell` and play no part in the auth redirect logic. Pageless routes are torn down
  with the page beneath them, so a 401 while on Profile still lands correctly on Login.
- `HomeShell` builds all three tabs eagerly via `IndexedStack`, so `historyProvider` fires its
  first request the moment the app reaches `/home` — not when the tab is opened.

## Known traps

- **`redirect`'s `authenticated` branch sends every non-`/home` location to `/home`.** Fine for
  today's three routes; it will make `/orders/:id` unreachable when Order Details lands.
- **History filters `status == 'Delivered'` client-side while `hasMore` comes from the unfiltered
  paginator.** A page with no delivered orders renders the empty state instead of the `ListView`,
  so the scroll controller never attaches and `loadMore()` can never fire — later pages become
  unreachable. A backend `?status=` filter is the real fix.
- **`Order.fromJson` has never parsed a real order** (the test account has none), so its field
  mappings and the `'Delivered'` string are unverified guesses.
- **`_bootstrap` calls `readToken()` outside its try/catch.** `flutter_secure_storage` can throw on
  Android after an algorithm change; if it does, `state` is never assigned, auth stays `unknown`,
  and the splash redirect strands the app there permanently.
