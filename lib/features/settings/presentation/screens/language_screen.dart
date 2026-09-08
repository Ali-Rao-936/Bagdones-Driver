import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/locale_provider.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      // RadioGroup owns the selection: RadioListTile's own
      // groupValue/onChanged were deprecated after Flutter 3.32.
      body: RadioGroup<Locale>(
        groupValue: currentLocale,
        onChanged: (locale) {
          if (locale != null) {
            ref.read(localeProvider.notifier).setLocale(locale);
          }
        },
        child: const Column(
          children: [
            RadioListTile<Locale>(
              title: Text('English'),
              value: Locale('en'),
            ),
            RadioListTile<Locale>(
              title: Text('العربية'),
              value: Locale('ar'),
            ),
          ],
        ),
      ),
    );
  }
}
