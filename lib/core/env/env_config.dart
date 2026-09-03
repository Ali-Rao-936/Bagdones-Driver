/// Central place for environment-specific values.
///
/// For now there is only production, since the backend team hasn't
/// shared a staging URL yet. When they do, switch on
/// `--dart-define=ENV=staging` instead of hardcoding.
class EnvConfig {
  EnvConfig._();

  static const String baseUrl = 'https://api.zaytoon.xyz/api/v1.0';

  /// Bump this if the backend ever changes the API version path.
  static const String apiVersion = 'v1.0';
}
