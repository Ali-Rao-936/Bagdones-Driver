import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_storage_service.dart';

/// English/Arabic only. The driver's choice is persisted, so the app
/// reopens in the language they picked rather than reverting to
/// English on every launch.
class LocaleNotifier extends Notifier<Locale> {
  static const supportedCodes = ['en', 'ar'];

  late final SecureStorageService _storage;

  @override
  Locale build() {
    _storage = SecureStorageService();
    _restore();
    // English until the stored choice loads — a frame or two later.
    return const Locale('en');
  }

  /// Nothing may touch `state` before the first await here: this runs
  /// from build(), which has not yet returned the initial value.
  Future<void> _restore() async {
    String? code;
    try {
      code = await _storage.readLocale();
    } catch (_) {
      // Storage unavailable (or an Android keystore reset) — English
      // is a fine fallback, and this must not break startup.
      return;
    }
    if (code != null && supportedCodes.contains(code)) {
      state = Locale(code);
    }
  }

  void setLocale(Locale locale) {
    assert(
      supportedCodes.contains(locale.languageCode),
      'Only en/ar are supported right now',
    );
    state = locale;
    unawaited(_storage.saveLocale(locale.languageCode));
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
