import 'package:flutter/material.dart';

import 'history_tab.dart';
import 'live_tab.dart';
import 'settings_tab.dart';

import '../../../../l10n/app_localizations.dart';

/// The 3-tab structure: Live, History, Settings. Each tab is its own
/// file so they stay easy to build out independently — the Live tab
/// is where it's worth spending the most design time.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  /// Tabs are built on first visit, then kept alive.
  ///
  /// A plain `IndexedStack` constructs every child immediately, which
  /// meant History fired its own `GET /delivery/orders` at startup
  /// alongside Live's — two identical requests for a tab the driver
  /// had not opened. Unvisited tabs are placeholders until selected.
  ///
  /// They stay mounted afterwards rather than being torn down, so
  /// Live keeps polling (and holds its push subscription) while the
  /// driver is looking at another tab.
  final _visited = <int>{0};

  static const _tabs = [LiveTab(), HistoryTab(), SettingsTab()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            if (_visited.contains(i)) _tabs[i] else const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _visited.add(i);
        }),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.local_shipping_outlined),
            label: l10n.tabLive,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history),
            label: l10n.tabHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
