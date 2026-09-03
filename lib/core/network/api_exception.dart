/// Maps the backend's error shapes (see the driver workflow doc) to
/// something the UI can react to without knowing about Dio or HTTP
/// status codes.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

/// 401 — no token, or token invalid/expired. The UI should clear the
/// session and send the driver back to Login.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Session expired']);
}

/// 403 — inactive account, or "not your order". Show as a banner,
/// don't force logout unless it's the inactive-account case.
class ForbiddenException extends ApiException {
  const ForbiddenException([super.message = 'Not allowed']);
}

/// 400/422 — validation or state errors (e.g. trying to mark an
/// order delivered that isn't In_Delivery yet). Always carries the
/// backend's own message so the UI can just display it.
class ValidationException extends ApiException {
  const ValidationException(super.message);
}

/// No connection, timeout, DNS failure, etc.
class NetworkException extends ApiException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Anything else — 500s, unexpected shapes.
class UnknownApiException extends ApiException {
  const UnknownApiException([super.message = 'Something went wrong']);
}
