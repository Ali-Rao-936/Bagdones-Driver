/// Defensive JSON readers for this backend's conventions.
///
/// Money arrives as JSON *strings* — `"delivery_fee": "1.23"`, and the
/// same for `total`, `price` and `profit_amount` — so a plain
/// `as num` cast throws and takes the whole list parse down with it.
/// Timestamps arrive space-separated (`2026-09-16 21:52:48`) rather
/// than as strict ISO-8601.
///
/// These coerce instead of asserting, so one odd field degrades that
/// single value rather than failing the request.
library;

double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// `DateTime.tryParse` accepts the space-separated form the API uses.
DateTime? asDate(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
