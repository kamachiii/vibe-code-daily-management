import 'package:http/http.dart' as http;
import 'package:smart_planner/core/config/env.dart';

/// Thin wrapper around [http.Client] with base-URL and auth-header injection.
///
/// For most Supabase calls, prefer [SupabaseClient] directly.
/// This client is useful for third-party REST endpoints.
class AppHttpClient {
  AppHttpClient({http.Client? inner}) : _inner = inner ?? http.Client();

  final http.Client _inner;

  /// Default headers sent with every request.
  Map<String, String> get _defaultHeaders => {
        'apikey': Env.supabaseAnonKey,
        'Content-Type': 'application/json',
      };

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    return _inner.get(uri, headers: {..._defaultHeaders, ...?headers});
  }

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _inner.post(
      uri,
      headers: {..._defaultHeaders, ...?headers},
      body: body,
    );
  }

  void close() => _inner.close();
}
