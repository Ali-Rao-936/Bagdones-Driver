import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] so the rest of the app only ever
/// deals with "get/set/clear the token" — not the storage plugin
/// directly. Makes it trivial to swap the underlying mechanism later
/// without touching anything above this layer.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'driver_auth_token';
  static const _localeKey = 'driver_locale';

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  /// The driver's chosen language code. Not a secret, but it rides
  /// along here rather than pulling in a second storage plugin for a
  /// single string. Losing it (e.g. the Android keystore reset we've
  /// seen) just falls back to English.
  Future<String?> readLocale() => _storage.read(key: _localeKey);

  Future<void> saveLocale(String languageCode) =>
      _storage.write(key: _localeKey, value: languageCode);
}
