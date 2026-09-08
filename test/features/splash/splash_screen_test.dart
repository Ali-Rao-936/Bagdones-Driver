import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaytoon_rider/core/network/connectivity_service.dart';
import 'package:zaytoon_rider/features/auth/presentation/providers/auth_provider.dart';
import 'package:zaytoon_rider/features/splash/presentation/screens/splash_screen.dart';

/// The offline branch of `_bootstrap` returns before `readToken()`, so
/// nothing here reaches a platform channel.
class _OfflineConnectivity implements ConnectivityService {
  @override
  Future<bool> hasConnection() async => false;
}

void main() {
  testWidgets('holds on splash and offers a retry when offline', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityServiceProvider.overrideWithValue(_OfflineConnectivity()),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    // Let build()'s fire-and-forget _bootstrap resolve.
    await tester.pump();
    await tester.pump();

    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // The critical part: status must stay `unknown`, because that is
    // what pins the router to /splash instead of falling through to
    // Login.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SplashScreen)),
    );
    expect(container.read(authProvider).status, AuthStatus.unknown);
  });
}
