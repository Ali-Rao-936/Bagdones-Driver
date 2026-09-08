import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../locale/locale_provider.dart';
import '../storage/secure_storage_service.dart';
import 'api_client.dart';

/// Single shared ApiClient for the whole app. AuthRepository and
/// OrdersRepository both read this instead of each constructing
/// their own instance — one place handling the auth header, the
/// Accept-Language header, and global 401s, instead of two
/// independent Dio instances drifting apart over time.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = SecureStorageService();
  return ApiClient(
    getToken: storage.readToken,
    getLocale: () => ref.read(localeProvider).languageCode,
    onUnauthorized: () async {
      await storage.clearToken();
      ref.read(authProvider.notifier).forceLogout();
    },
  );
});
