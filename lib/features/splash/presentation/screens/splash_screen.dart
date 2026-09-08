import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

/// Shown while [AuthNotifier] is checking connectivity and looking for
/// a stored session on launch (AuthStatus.unknown).
///
/// When the connectivity probe fails the status deliberately stays
/// `unknown`, so the router holds here — this screen then explains why
/// and offers a retry rather than leaving a bare spinner spinning
/// forever.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final offlineMessage = auth.errorMessage;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Zaytoon Driver',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              if (offlineMessage == null)
                const CircularProgressIndicator()
              else ...[
                Icon(
                  Icons.wifi_off_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  offlineMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => ref.read(authProvider.notifier).retry(),
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
