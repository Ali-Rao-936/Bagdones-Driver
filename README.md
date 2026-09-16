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
    notifications/  PushService — FCM permission, token, message streams
    locale/     English/Arabic locale state
  features/
    auth/       Driver model, AuthRepository (login / me / logout), AuthNotifier
    orders/     Order models, OrdersRepository, Live + History + detail providers
    settings/   Profile, Language, Help, About
    splash/     Shown while the session and connectivity are resolved
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

Working end to end against the live backend, verified on real orders and real
devices: login and session restore, a splash that holds when offline, the Live
tab (30s polling, new-order detection, mark delivered), History, Order Details,
Settings with its four sub-screens, and push notifications on both platforms.

Still to build:
- Sending the FCM token to the backend — no endpoint exists for it yet
- Turn-by-turn navigation. `google_maps_link` is a `?q=lat,lng` pin, so it drops
  a marker rather than starting directions; the response carries `geo_location`
  if we want to build a real directions URL
- A currency prefix on amounts — they render as bare numbers
- Real visual design for Login; it's functional, not designed

Open questions for the backend:
- `selected_choices_string` sometimes holds a genuine item option ("Pistachio")
  and sometimes the store name ("Primo Supermarket"), within the same order,
  while the typed `compulsory_choices`/`multiple_choices` lists stay empty
- No `?status=` filter on `/delivery/orders`, so Live and History both fetch
  everything and filter client-side
- `delivered_at` has no timezone marker, unlike `created_at` — so it may be
  UTC being rendered as local

## Development

```bash
flutter analyze                        # keep at "No issues found!"
flutter test                           # full suite
flutter test <path>                    # single file
flutter test --plain-name '<name>'     # single test
```

See [CLAUDE.md](CLAUDE.md) for architectural constraints worth knowing before changing
routing, networking, or error handling.
