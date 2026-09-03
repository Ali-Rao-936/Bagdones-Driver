# Zaytoon Rider App — Phase 0 scaffold

What's here:
- `core/` — env config, API client (Dio + interceptors), secure token storage, locale state, router
- `features/auth/` — Driver model, AuthRepository (login/me/logout), AuthNotifier (session state)
- `features/home/` — the 3-tab shell (Live / History / Settings), each tab a stub for now

## Run it
1. `flutter create .` in this folder if you haven't generated the platform folders yet (android/ios/etc.), or copy these files into an existing `flutter create` project.
2. `flutter pub get`
3. `flutter run`

Login should work end-to-end against `https://api.zaytoon.xyz` with valid driver credentials — that's the point of Phase 0, proving the plumbing works before building real UI.

## What's deliberately left as TODO (Phase 1+)
- Live tab: the polling provider + "new order" detection banner/sound
- History tab: paginated order list
- Settings tab: profile, language switcher, help
- Order Details screen (shared by Live + History)
- Making Login actually look good — this version is functional, not designed

## Notes
- Riverpod providers here are manual (no `@riverpod` codegen) — matches what the official docs recommend for a first project.
- `ApiClient` takes its token/locale/unauthorized-handling as callbacks so it has zero dependency on Riverpod — keeps it independently testable, and means swapping polling for FCM later won't touch this file.
- FCM isn't wired up yet — real work for when we build the Live tab, since the backend needs a corresponding change too.
