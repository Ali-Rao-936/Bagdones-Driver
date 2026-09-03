# Zaytoon Rider App

Flutter app for Zaytoon delivery drivers — log in, see live orders, review past
deliveries. Backend is `https://api.zaytoon.xyz/api/v1.0`.

Runs on Android, iOS, and web.

## Getting started

```bash
flutter pub get
flutter run -d <device-id>    # flutter devices to list ids
```

## What's in here

```
lib/
  core/
    env/        EnvConfig — base URL and API version
    network/    ApiClient (Dio + interceptors), ApiException hierarchy
    router/     GoRouter setup, auth-driven redirects
    storage/    SecureStorageService — the auth token
    locale/     English/Arabic locale state
  features/
    auth/       Driver model, AuthRepository (login / me / logout), AuthNotifier
    home/       3-tab shell: Live, History, Settings
test/           widget tests
```

**Auth** — `AuthNotifier` owns the session. On launch it reads the stored token and
calls `/delivery/me`, resolving to authenticated or unauthenticated; until then its
status is `unknown` and routing waits. A 401 anywhere clears the token and bounces the
driver back to Login.

**Routing** — one `GoRouter` instance for the app's lifetime. It listens to auth
*status* changes through a `refreshListenable` rather than rebuilding on every state
change, so screens keep their local state (typed-in text, scroll position) when
something like an error message updates.

**Networking** — `ApiClient` wraps Dio and takes its token, locale, and
unauthorized-handling as callbacks, so it has no dependency on Riverpod or any feature
and can be tested on its own. Interceptors attach the bearer token and
`Accept-Language` (the backend localizes its responses). Dio errors map to a sealed
`ApiException` hierarchy carrying the backend's own message, so the UI never touches
HTTP status codes.

In debug builds a logging interceptor prints every request, response, and error with
timings; tokens and passwords are redacted and bodies truncated.

**State** — Riverpod, written by hand (no `@riverpod` codegen).

## Current state

The plumbing is real and works end-to-end: login against the live backend, token
persistence, session restore, auth-driven routing. The UI is minimal on purpose.

Still to build:
- Live tab — order polling and new-order detection (banner + sound)
- History tab — paginated order list
- Settings tab — profile, language switcher, help
- Order Details screen, shared by Live and History
- Real visual design for Login; it's functional, not designed
- FCM push, which needs a matching backend change

## Development

```bash
flutter analyze                        # keep at "No issues found!"
flutter test                           # full suite
flutter test <path>                    # single file
flutter test --plain-name '<name>'     # single test
```

See [CLAUDE.md](CLAUDE.md) for architectural constraints worth knowing before changing
routing, networking, or error handling.
