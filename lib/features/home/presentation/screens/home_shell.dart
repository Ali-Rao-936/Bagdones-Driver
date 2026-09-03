import 'package:flutter/material.dart';

import 'history_tab.dart';
import 'live_tab.dart';
import 'settings_tab.dart';

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

  static const _tabs = [LiveTab(), HistoryTab(), SettingsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
