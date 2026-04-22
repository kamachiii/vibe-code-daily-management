import 'package:intl/intl.dart';

/// ISO-8601 date-only string (YYYY-MM-DD) from a [DateTime].
String toDateString(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';

/// Parses an ISO-8601 date-only string (YYYY-MM-DD) to [DateTime] in local time.
DateTime? parseDateString(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

/// Short display format, e.g. "22 Apr 2026".
String formatShortDate(DateTime dt) => DateFormat('d MMM yyyy').format(dt);

/// Time display format, e.g. "09:30".
String formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

/// Parses "HH:MM" and returns a [Duration] from midnight.
Duration? parseHhmm(String? s) {
  if (s == null || s.isEmpty) return null;
  final parts = s.split(':');
  if (parts.length < 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return Duration(hours: h, minutes: m);
}
