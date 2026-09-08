import '../../../core/network/api_client.dart';
import '../domain/driver.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// POST /delivery/auth/login
  /// Throws an ApiException subtype on 401/403/422 — the backend's
  /// login error is intentionally generic (no "phone exists" leak),
  /// so just surface `message` as-is.
  Future<({Driver driver, String token})> login({
    required String phoneNumber,
    required String password,
  }) async {
    final response = await _client.post(
      '/delivery/auth/login',
      data: {'phone_number': phoneNumber, 'password': password},
    );
    final data = _client.unwrap(response);
    return (
      driver: Driver.fromJson(data['delivery_man'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }

  /// GET /delivery/me — used right after login, and to restore a
  /// session on app launch if a token is already stored.
  Future<Driver> fetchMe() async {
    final response = await _client.get('/delivery/me');
    final data = _client.unwrap(response);
    return Driver.fromJson(data['delivery_man'] as Map<String, dynamic>);
  }

  /// POST /delivery/auth/logout — revokes only the current device's
  /// token, per the doc. We clear the local token regardless of
  /// whether this call succeeds.
  Future<void> logout() async {
    await _client.post('/delivery/auth/logout');
  }
}
