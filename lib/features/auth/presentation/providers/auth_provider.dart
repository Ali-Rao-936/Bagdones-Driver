import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/locale_provider.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_repository.dart';
import '../../domain/driver.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({required this.status, this.driver, this.errorMessage});

  const AuthState.unknown() : this(status: AuthStatus.unknown);

  final AuthStatus status;
  final Driver? driver;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    Driver? driver,
    String? errorMessage,
  }) => AuthState(
        status: status ?? this.status,
        driver: driver ?? this.driver,
        errorMessage: errorMessage,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  late final SecureStorageService _storage;
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _storage = SecureStorageService();
    _repository = AuthRepository(
      ApiClient(
        getToken: _storage.readToken,
        getLocale: () => ref.read(localeProvider).languageCode,
        onUnauthorized: _handleUnauthorized,
      ),
    );
    _bootstrap();
    return const AuthState.unknown();
  }

  Future<void> _bootstrap() async {
    final token = await _storage.readToken();
    if (token == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final driver = await _repository.fetchMe();
      state = state.copyWith(status: AuthStatus.authenticated, driver: driver);
    } on ApiException {
      await _storage.clearToken();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final result = await _repository.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      await _storage.saveToken(result.token);
      state = AuthState(status: AuthStatus.authenticated, driver: result.driver);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      rethrow;
    } catch (e) {
      // The call itself succeeded but we couldn't read the response
      // (shape/type mismatch). Don't blame the driver's credentials
      // for it — say what actually went wrong.
      debugPrint('Login succeeded but response parsing failed: $e');
      state = state.copyWith(
        errorMessage: 'Unexpected response from server. Please try again.',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on ApiException {
      // Ignore — we're clearing the local session regardless.
    }
    await _storage.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _handleUnauthorized() async {
    await _storage.clearToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
