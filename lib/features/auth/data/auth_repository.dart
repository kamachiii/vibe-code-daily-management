import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:smart_planner/core/error/app_exception.dart';

/// Handles authentication via Supabase Auth.
class AuthRepository {
  AuthRepository(this._supabase);

  final supa.SupabaseClient _supabase;

  // ── Getters ──────────────────────────────────────────────────────────────

  supa.User? get currentUser => _supabase.auth.currentUser;

  Stream<supa.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // ── Sign in / Sign up ────────────────────────────────────────────────────

  /// Sign in with email and password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth
          .signInWithPassword(email: email, password: password);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode, cause: e);
    }
  }

  /// Register a new user with email and password.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _supabase.auth.signUp(email: email, password: password);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message, code: e.statusCode, cause: e);
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
