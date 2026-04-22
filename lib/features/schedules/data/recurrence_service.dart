import 'package:smart_planner/features/schedules/domain/schedule_item.dart';
import 'package:smart_planner/features/schedules/domain/schedule_rule.dart';

/// Generates concrete [ScheduleItem] instances from a [ScheduleRule] within a
/// date range.  Currently a stub — replace with full RRULE-style logic.
///
/// Strategy: generate 30 days ahead from today; re-run when rule changes.
class RecurrenceService {
  /// Returns the dates on which [rule] occurs within [from]…[to] (inclusive).
  List<DateTime> expandDates({
    required ScheduleRule rule,
    required DateTime from,
    required DateTime to,
  }) {
    // TODO: implement RRULE-style date expansion.
    // Algorithm outline:
    //   1. Start at max(rule.startDate, from).
    //   2. Iterate by rule.interval (days/weeks/months depending on recurrenceType).
    //   3. For 'weekly'/'custom', only include dates where weekday is in daysOfWeek.
    //   4. Stop at min(rule.endDate, to).
    return [];
  }

  /// Generates [ScheduleItem] instances for [rule] in the next [days] days.
  List<ScheduleItem> generateItems({
    required ScheduleRule rule,
    int days = 30,
  }) {
    final now = DateTime.now();
    final to = now.add(Duration(days: days));
    final dates = expandDates(rule: rule, from: now, to: to);

    return dates.map((date) {
      final startAt = rule.defaultStartTime != null
          ? _combineDateTime(date, rule.defaultStartTime!)
          : null;
      final endAt = rule.defaultEndTime != null
          ? _combineDateTime(date, rule.defaultEndTime!)
          : null;

      return ScheduleItem(
        id: '', // will be assigned by DB
        userId: rule.userId,
        ruleId: rule.id,
        title: rule.title,
        description: rule.description,
        kind: rule.kind,
        isAllDay: rule.isAllDay,
        startAt: startAt,
        endAt: endAt,
        notifyBeforeMinutes: rule.notifyBeforeMinutes,
      );
    }).toList();
  }

  DateTime _combineDateTime(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }
}
