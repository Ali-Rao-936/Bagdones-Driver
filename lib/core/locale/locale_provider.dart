import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// English/Arabic only for now, per the plan. Kept in-memory for
/// Phase 0 — we'll persist the driver's choice once we build the
/// Settings tab.
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  void setLocale(Locale locale) {
    assert(
      ['en', 'ar'].contains(locale.languageCode),
      'Only en/ar are supported right now',
    );
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
