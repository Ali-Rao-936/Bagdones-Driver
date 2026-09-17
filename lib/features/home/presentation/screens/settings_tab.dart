import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../settings/presentation/screens/about_screen.dart';
import '../../../settings/presentation/screens/help_screen.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../../../settings/presentation/screens/profile_screen.dart';
import '../../../../l10n/app_localizations.dart';

/// Grouped-card layout: the four navigable rows sit in one card;
/// Logout gets its own card below since it's a destructive action,
/// not a destination — keeping it visually separate is deliberate.
class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.person_outline,
                  label: l10n.settingsProfile,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  ),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.language_outlined,
                  label: l10n.settingsLanguage,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.help_outline,
                  label: l10n.settingsHelp,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  ),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: l10n.settingsAbout,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _confirmLogout(context, ref),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.settingsLogout,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
        title: Text(l10n.settingsLogoutConfirmTitle),
        content: Text(l10n.settingsLogoutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.settingsLogout),
          ),
        ],
      );
      },
    );

    // No manual navigation here — logout() sets authProvider's state
    // to unauthenticated, and the router's redirect (via
    // refreshListenable) sends us back to /login on its own.
    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
