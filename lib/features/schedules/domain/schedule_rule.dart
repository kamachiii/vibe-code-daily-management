/// Represents a recurring-rule template (e.g. "every Monday at 08:00").
class ScheduleRule {
  const ScheduleRule({
    required this.id,
    required this.userId,
    required this.title,
    required this.kind,
    required this.recurrenceType,
    required this.startDate,
    this.description,
    this.isAllDay = false,
    this.defaultStartTime,
    this.defaultEndTime,
    this.interval = 1,
    this.daysOfWeek = const [],
    this.endDate,
    this.notifyBeforeMinutes = 15,
    this.isEnabled = true,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;

  /// 'task' or 'event'
  final String kind;
  final bool isAllDay;

  /// Local time string "HH:MM".
  final String? defaultStartTime;
  final String? defaultEndTime;

  /// 'none' | 'daily' | 'weekly' | 'monthly' | 'custom'
  final String recurrenceType;
  final int interval;

  /// ISO day-of-week: 1 = Mon … 7 = Sun.
  final List<int> daysOfWeek;

  final DateTime startDate;
  final DateTime? endDate;
  final int notifyBeforeMinutes;
  final bool isEnabled;

  factory ScheduleRule.fromJson(Map<String, dynamic> json) {
    return ScheduleRule(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      kind: (json['kind'] as String?) ?? 'task',
      isAllDay: (json['is_all_day'] as bool?) ?? false,
      defaultStartTime: json['default_start_time'] as String?,
      defaultEndTime: json['default_end_time'] as String?,
      recurrenceType: (json['recurrence_type'] as String?) ?? 'none',
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      daysOfWeek: ((json['days_of_week'] as List?) ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      notifyBeforeMinutes:
          (json['notify_before_minutes'] as num?)?.toInt() ?? 15,
      isEnabled: (json['is_enabled'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'kind': kind,
        'is_all_day': isAllDay,
        'default_start_time': defaultStartTime,
        'default_end_time': defaultEndTime,
        'recurrence_type': recurrenceType,
        'interval': interval,
        'days_of_week': daysOfWeek,
        'start_date':
            '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
        'end_date': endDate != null
            ? '${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}'
            : null,
        'notify_before_minutes': notifyBeforeMinutes,
        'is_enabled': isEnabled,
      };
}
