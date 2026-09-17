import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Static content for now — revisit if you want a real FAQ or a
/// WhatsApp/call link to support instead.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const headingStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.helpGettingOrderTitle, style: headingStyle),
              const SizedBox(height: 8),
              Text(l10n.helpGettingOrderBody),
              const SizedBox(height: 20),
              Text(l10n.helpMarkDeliveredTitle, style: headingStyle),
              const SizedBox(height: 8),
              Text(l10n.helpMarkDeliveredBody),
              const SizedBox(height: 20),
              Text(l10n.helpMoreTitle, style: headingStyle),
              const SizedBox(height: 8),
              Text(l10n.helpMoreBody),
            ],
          ),
        ),
      ),
    );
  }
}
