import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

/// Read-only for now — there's no driver-facing "update my info"
/// endpoint in the current backend; name/phone/password are all set
/// by the admin. Revisit if that changes.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(authProvider).driver;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: driver == null
          ? const Center(child: Text('No profile data available'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge_outlined),
                        title: const Text('Name'),
                        subtitle: Text(driver.name),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('Phone'),
                        subtitle: Text(driver.phoneNumber),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.verified_outlined),
                        title: const Text('Account status'),
                        subtitle: Text(driver.isActive ? 'Active' : 'Inactive'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
