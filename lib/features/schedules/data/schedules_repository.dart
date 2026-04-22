import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_planner/features/schedules/domain/schedule_item.dart';
import 'package:smart_planner/features/schedules/domain/schedule_rule.dart';

/// Provides CRUD access to `schedule_items` and `schedule_rules` tables.
class SchedulesRepository {
  SchedulesRepository(this._supabase);

  final SupabaseClient _supabase;

  // ── Schedule Items ────────────────────────────────────────────────────────

  /// Returns items for [userId] with start_at or due_at within [from]…[to].
  Future<List<ScheduleItem>> fetchItems({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _supabase
        .from('schedule_items')
        .select()
        .eq('user_id', userId)
        .gte('start_at', from.toIso8601String())
        .lte('start_at', to.toIso8601String())
        .order('start_at');

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ScheduleItem.fromJson)
        .toList();
  }

  Future<ScheduleItem> createItem(ScheduleItem item) async {
    final row = item.toJson()..remove('id');
    final data =
        await _supabase.from('schedule_items').insert(row).select().single();
    return ScheduleItem.fromJson(data);
  }

  Future<ScheduleItem> updateItem(ScheduleItem item) async {
    final data = await _supabase
        .from('schedule_items')
        .update(item.toJson())
        .eq('id', item.id)
        .select()
        .single();
    return ScheduleItem.fromJson(data);
  }

  Future<void> deleteItem(String itemId) async {
    await _supabase.from('schedule_items').delete().eq('id', itemId);
  }

  // ── Schedule Rules ────────────────────────────────────────────────────────

  Future<List<ScheduleRule>> fetchRules(String userId) async {
    final data = await _supabase
        .from('schedule_rules')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return (data as List)
        .cast<Map<String, dynamic>>()
        .map(ScheduleRule.fromJson)
        .toList();
  }

  Future<ScheduleRule> createRule(ScheduleRule rule) async {
    final row = rule.toJson()..remove('id');
    final data =
        await _supabase.from('schedule_rules').insert(row).select().single();
    return ScheduleRule.fromJson(data);
  }

  Future<void> deleteRule(String ruleId) async {
    await _supabase.from('schedule_rules').delete().eq('id', ruleId);
  }
}
