import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_shell.dart';

/// Bridges [authProvider] to something GoRouter can listen to.
///
/// Only notifies on a *status* change (not on every AuthState change,
/// e.g. an error message) — that's the difference between "re-run
/// redirect" and "tear down every screen's local state", which is
/// what plain `ref.watch(authProvider)` inside the router provider
/// used to do.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Built once and kept alive — the same [GoRouter] instance persists
/// across auth state changes. `redirect` reads the latest auth
/// status itself (via `ref.read`) whenever GoRouter re-evaluates it,
/// which `refreshListenable` triggers.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login';

      switch (auth.status) {
        case AuthStatus.unknown:
          return null; // splash/loading — stay put until we know
        case AuthStatus.unauthenticated:
          return loggingIn ? null : '/login';
        case AuthStatus.authenticated:
          return loggingIn ? '/home' : null;
      }
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeShell()),
    ],
  );
});
