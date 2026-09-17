import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      // RadioGroup owns the selection: RadioListTile's own
      // groupValue/onChanged were deprecated after Flutter 3.32.
      body: RadioGroup<Locale>(
        groupValue: currentLocale,
        onChanged: (locale) {
          if (locale != null) {
            ref.read(localeProvider.notifier).setLocale(locale);
          }
        },
        child: Column(
          children: [
            RadioListTile<Locale>(
              title: Text(l10n.languageEnglish),
              value: const Locale('en'),
            ),
            RadioListTile<Locale>(
              title: Text(l10n.languageArabic),
              value: const Locale('ar'),
            ),
          ],
        ),
      ),
    );
  }
}
