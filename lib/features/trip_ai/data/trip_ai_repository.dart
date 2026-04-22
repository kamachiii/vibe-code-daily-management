import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_planner/core/error/app_exception.dart';
import 'package:smart_planner/core/utils/datetime.dart';
import 'package:smart_planner/features/trip_ai/domain/trip_plan.dart';

/// Calls the Supabase Edge Function `trip-plan` which internally invokes
/// Google Gemini and returns a strict-JSON trip plan.
class TripAiRepository {
  TripAiRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Generates a trip plan via the `trip-plan` Edge Function.
  ///
  /// [destination]  — free-text destination (e.g. "Yogyakarta").
  /// [startDate]    — first day of the trip.
  /// [days]         — number of days (1–7).
  /// [preferences]  — optional user preferences map forwarded to the prompt.
  /// [budgetTotal]  — optional total budget in user currency.
  Future<TripPlan> generateTripPlan({
    required String destination,
    required DateTime startDate,
    required int days,
    Map<String, dynamic> preferences = const {},
    int budgetTotal = 0,
  }) async {
    assert(days >= 1 && days <= 7, 'days must be between 1 and 7');

    final payload = {
      'destination': destination,
      'start_date': toDateString(startDate),
      'days': days,
      'budget_total': budgetTotal,
      'preferences': preferences,
    };

    final FunctionResponse res;
    try {
      res = await _supabase.functions.invoke(
        'trip-plan',
        body: payload,
      );
    } catch (e) {
      throw NetworkException(
        'Failed to call trip-plan edge function',
        cause: e,
      );
    }

    if (res.status != 200) {
      throw NetworkException(
        'trip-plan returned status ${res.status}',
        code: res.status.toString(),
      );
    }

    final dynamic data = res.data;
    final Map<String, dynamic> jsonMap;

    try {
      if (data is Map<String, dynamic>) {
        jsonMap = data;
      } else if (data is String) {
        jsonMap = jsonDecode(data) as Map<String, dynamic>;
      } else {
        throw ParseException(
          'Unexpected response type: ${data.runtimeType}',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw ParseException('Cannot parse trip-plan response', cause: e);
    }

    try {
      return TripPlan.fromJson(jsonMap);
    } catch (e) {
      throw ParseException('Cannot map trip-plan JSON to TripPlan', cause: e);
    }
  }
}
