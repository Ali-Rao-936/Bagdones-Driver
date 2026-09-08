import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client_provider.dart';
import '../../../../core/network/connectivity_service.dart';
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
    _repository = AuthRepository(ref.read(apiClientProvider));
    _bootstrap();
    return const AuthState.unknown();
  }

  /// Re-runs startup. The splash screen's Retry button calls this
  /// after a failed connectivity check. Safe to touch `state` here —
  /// unlike `_bootstrap`, this only ever runs after build().
  Future<void> retry() async {
    state = state.copyWith(errorMessage: null);
    await _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Nothing may read `state` before the first await: _bootstrap is
    // kicked off from build(), which has not yet returned the initial
    // value, and reading it there throws "uninitialized provider".
    final isOnline = await ref.read(connectivityServiceProvider).hasConnection();

    // Offline: leave status at `unknown` on purpose. The router pins
    // that state to /splash, so the app holds there instead of
    // dropping to Login and offering a sign-in that cannot succeed.
    if (!isOnline) {
      state = state.copyWith(errorMessage: 'No internet connection');
      return;
    }

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
    } catch (e) {
      // Not an auth failure — the call worked, we just couldn't read
      // the response. Keep the token (it may well still be valid) but
      // resolve the status anyway: leaving it `unknown` strands the
      // app on the splash screen with no way forward.
      debugPrint('Session restore failed to parse /delivery/me: $e');
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

  /// Called by [apiClientProvider] when any request 401s. That
  /// callback clears the token itself, so this only resets state.
  void forceLogout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
