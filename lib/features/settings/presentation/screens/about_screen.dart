import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About app')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.hasData
                ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                : '...';

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Zaytoon Driver', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Version $version', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 24),
                  Text('Privacy policy', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Text('Placeholder privacy policy text — replace with the real policy before release.'),
                  const SizedBox(height: 20),
                  Text('Terms of service', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  const Text('Placeholder terms text — replace with the real terms before release.'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
