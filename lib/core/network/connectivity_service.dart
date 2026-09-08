import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env_config.dart';

/// Answers "can we actually reach the backend?" rather than "is there
/// a network interface?".
///
/// Deliberately uses its own bare [Dio] rather than [ApiClient]: the
/// shared client attaches the auth header and routes 401s to
/// `onUnauthorized`, and a probe that logs the driver out would be
/// worse than no probe at all.
class ConnectivityService {
  ConnectivityService([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
                // Any HTTP response proves reachability — a 404 or 401
                // from the server is just as good as a 200 here.
                validateStatus: (_) => true,
              ),
            );

  final Dio _dio;

  Future<bool> hasConnection() async {
    try {
      await _dio.get<void>(EnvConfig.baseUrl);
      debugPrint('Connectivity probe: online');
      return true;
    } on DioException catch (e) {
      debugPrint('Connectivity probe: offline (${e.type.name})');
      return false;
    }
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => ConnectivityService(),
);
