import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
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
                  Text(
                    l10n.appTitle,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.aboutVersion(version),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.aboutPrivacyTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(l10n.aboutPrivacyBody),
                  const SizedBox(height: 20),
                  Text(l10n.aboutTermsTitle, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(l10n.aboutTermsBody),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
