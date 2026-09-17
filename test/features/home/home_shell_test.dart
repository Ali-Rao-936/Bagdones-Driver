import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaytoon_rider/features/home/presentation/screens/history_tab.dart';
import 'package:zaytoon_rider/l10n/app_localizations.dart';
import 'package:zaytoon_rider/features/home/presentation/screens/home_shell.dart';
import 'package:zaytoon_rider/features/home/presentation/screens/live_tab.dart';
import 'package:zaytoon_rider/features/orders/presentation/providers/history_provider.dart';
import 'package:zaytoon_rider/features/orders/presentation/providers/live_orders_provider.dart';

/// Both fakes override build() so the real ones' startup fetch and
/// 30s poll timer never run — a pending timer would fail the test,
/// and the network is irrelevant to what's being checked here.
class _FakeLiveOrders extends LiveOrdersNotifier {
  @override
  LiveOrdersState build() => const LiveOrdersState();
}

class _FakeHistory extends HistoryNotifier {
  @override
  HistoryState build() => const HistoryState();
}

void main() {
  Future<void> pumpShell(WidgetTester tester) => tester.pumpWidget(
        ProviderScope(
          overrides: [
            liveOrdersProvider.overrideWith(_FakeLiveOrders.new),
            historyProvider.overrideWith(_FakeHistory.new),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: HomeShell()),
        ),
      );

  testWidgets('does not build History until its tab is opened', (tester) async {
    await pumpShell(tester);

    expect(find.byType(LiveTab), findsOneWidget);
    // skipOffstage: false matters. IndexedStack wraps unselected
    // children in Visibility.maintain, so they are offstage and the
    // default finder skips them — this assertion would pass even with
    // the tabs built eagerly, which is exactly the bug it guards.
    expect(find.byType(HistoryTab, skipOffstage: false), findsNothing);
  });

  testWidgets('keeps Live alive after switching to History', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryTab), findsOneWidget);
    // Still mounted, just offstage — this is what keeps Live polling
    // while the driver is on another tab.
    expect(find.byType(LiveTab, skipOffstage: false), findsOneWidget);
  });
}
