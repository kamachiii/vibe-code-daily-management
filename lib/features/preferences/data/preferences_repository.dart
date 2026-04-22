import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_planner/features/preferences/domain/user_preferences.dart';

/// CRUD for the `preferences` Supabase table.
class PreferencesRepository {
  PreferencesRepository(this._supabase);

  final SupabaseClient _supabase;

  Future<UserPreferences?> fetchForUser(String userId) async {
    final data = await _supabase
        .from('preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserPreferences.fromJson(data);
  }

  Future<void> upsert(UserPreferences prefs) async {
    await _supabase.from('preferences').upsert(prefs.toJson());
  }
}
