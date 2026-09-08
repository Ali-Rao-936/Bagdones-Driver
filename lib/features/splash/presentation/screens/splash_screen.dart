import 'package:flutter/material.dart';

/// Shown while [AuthNotifier] is checking for a stored session on
/// launch (AuthStatus.unknown). Placeholder on purpose — swap in a
/// logo or animation later, the router doesn't care what's here.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello Driver',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
