import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

/// Read-only for now — there's no driver-facing "update my info"
/// endpoint in the current backend; name/phone/password are all set
/// by the admin. Revisit if that changes.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final driver = ref.watch(authProvider).driver;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: driver == null
          ? Center(child: Text(l10n.profileNone))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: Text(l10n.profileName),
                        subtitle: Text(driver.name),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(l10n.profilePhone),
                        subtitle: Text(driver.phoneNumber),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: Text(l10n.profileStatus),
                        subtitle: Text(
                          driver.isActive ? l10n.profileActive : l10n.profileInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
