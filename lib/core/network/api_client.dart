import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../env/env_config.dart';
import 'api_exception.dart';

/// Thin wrapper around Dio.
///
/// Nothing in here knows about Riverpod, go_router, or any specific
/// feature — it just knows how to talk to the backend and how to
/// turn Dio's errors into [ApiException]s. Auth/token state lives
/// in the auth feature and is *injected* here via callbacks, so this
/// class stays easy to test on its own, and easy to swap later (e.g.
/// if the "new order" source changes from polling to FCM, this file
/// doesn't need to change at all).
class ApiClient {
  ApiClient({
    required Future<String?> Function() getToken,
    required String Function() getLocale,
    required Future<void> Function() onUnauthorized,
  })  : _getToken = getToken,
        _getLocale = getLocale,
        _onUnauthorized = onUnauthorized {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Backend returns localized content based on the driver's
          // chosen language (English/Arabic).
          options.headers['Accept-Language'] = _getLocale();
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Debug builds only — stripped from release by the kDebugMode
    // const, so no request/response bodies can leak in production.
    if (kDebugMode) {
      _dio.interceptors.add(_DebugLogInterceptor());
    }
  }

  late final Dio _dio;
  final Future<String?> Function() _getToken;
  final String Function() _getLocale;
  final Future<void> Function() _onUnauthorized;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.get(path, queryParameters: queryParameters));

  Future<Response<dynamic>> post(String path, {Object? data}) =>
      _request(() => _dio.post(path, data: data));

  Future<Response<dynamic>> patch(String path, {Object? data}) =>
      _request(() => _dio.patch(path, data: data));
  Map<String, dynamic> unwrap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }

  Future<Response<dynamic>> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final serverMessage = (data is Map && data['message'] is String)
        ? data['message'] as String
        : null;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      default:
        break;
    }

    switch (status) {
      case 401:
        return UnauthorizedException(serverMessage ?? 'Invalid credentials');
      case 403:
        return ForbiddenException(serverMessage ?? 'Not allowed');
      case 400:
      case 422:
        return ValidationException(
            serverMessage ?? 'Request could not be completed');
      default:
        return const UnknownApiException();
    }
  }
}

/// Logs every request/response/error to the console in debug builds.
///
/// Registered only under [kDebugMode]. Anything that could end up in
/// a bug report — tokens, passwords — is redacted rather than
/// printed, and bodies are truncated so a large order list doesn't
/// flood the console.
class _DebugLogInterceptor extends Interceptor {
  static const _bodyLimit = 1000;
  static const _redactedKeys = {'password', 'token', 'access_token'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_startedAt'] = DateTime.now();
    debugPrint('→ ${options.method} ${options.uri}');
    debugPrint('  headers: ${_redactMap(options.headers)}');
    if (options.data != null) {
      debugPrint('  body: ${_format(options.data)}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}${_elapsed(response.requestOptions)}',
    );
    debugPrint('  body: ${_format(response.data)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint(
      '✗ ${err.response?.statusCode ?? err.type.name} '
      '${err.requestOptions.method} ${err.requestOptions.uri}'
      '${_elapsed(err.requestOptions)}',
    );
    if (err.response?.data != null) {
      debugPrint('  body: ${_format(err.response!.data)}');
    } else {
      debugPrint('  error: ${err.message}');
    }
    handler.next(err);
  }

  String _elapsed(RequestOptions options) {
    final startedAt = options.extra['_startedAt'];
    if (startedAt is! DateTime) return '';
    return ' (${DateTime.now().difference(startedAt).inMilliseconds}ms)';
  }

  /// Replaces sensitive values, so a pasted log can't hand someone a
  /// live session.
  Map<String, dynamic> _redactMap(Map<String, dynamic> source) => {
        for (final entry in source.entries)
          entry.key: _redactedKeys.contains(entry.key.toLowerCase()) ||
                  entry.key.toLowerCase() == 'authorization'
              ? '***'
              : entry.value,
      };

  String _format(Object? data) {
    final redacted = data is Map<String, dynamic> ? _redactMap(data) : data;
    var text = redacted is Map || redacted is List
        ? const JsonEncoder.withIndent('  ').convert(redacted)
        : redacted.toString();
    if (text.length > _bodyLimit) {
      text = '${text.substring(0, _bodyLimit)}… (${text.length} chars)';
    }
    return text;
  }
}
