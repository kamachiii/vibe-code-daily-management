import 'dart:convert';

import 'package:smart_planner/core/error/app_exception.dart';

/// Safely decodes a JSON string, throwing [ParseException] on failure.
Map<String, dynamic> parseJsonObject(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const ParseException('Expected a JSON object at the top level');
  } on FormatException catch (e) {
    throw ParseException('Invalid JSON: ${e.message}', cause: e);
  }
}

/// Safely casts [value] to [T] or returns null.
T? tryCast<T>(dynamic value) => value is T ? value : null;

/// Reads a string field from [json], returning [fallback] when absent/null.
String readString(Map<String, dynamic> json, String key, {String fallback = ''}) {
  return (json[key] as String?) ?? fallback;
}

/// Reads an int field from [json], returning [fallback] when absent/null.
int readInt(Map<String, dynamic> json, String key, {int fallback = 0}) {
  return (json[key] as num?)?.toInt() ?? fallback;
}

/// Reads a bool field from [json], returning [fallback] when absent/null.
bool readBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  return (json[key] as bool?) ?? fallback;
}

/// Reads a nullable list, mapping each element via [fromElement].
List<T> readList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) fromElement,
) {
  final raw = json[key];
  if (raw == null) return [];
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(fromElement)
      .toList();
}
