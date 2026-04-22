/// A concrete schedule instance that appears in the user's calendar / task list.
class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.kind,
    this.ruleId,
    this.description,
    this.status = 'pending',
    this.startAt,
    this.endAt,
    this.dueAt,
    this.isAllDay = false,
    this.source = 'manual',
    this.externalProvider,
    this.externalId,
    this.notifyBeforeMinutes,
    this.notifyEnabled = true,
  });

  final String id;
  final String userId;
  final String? ruleId;
  final String title;
  final String? description;

  /// 'task' or 'event'
  final String kind;

  /// 'pending' | 'done' | 'cancelled'
  final String status;

  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? dueAt;
  final bool isAllDay;

  /// 'manual' | 'ai' | 'google_import'
  final String source;

  final String? externalProvider;
  final String? externalId;
  final int? notifyBeforeMinutes;
  final bool notifyEnabled;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: (json['id'] as String?) ?? '',
      userId: (json['user_id'] as String?) ?? '',
      ruleId: json['rule_id'] as String?,
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      kind: (json['kind'] as String?) ?? 'task',
      status: (json['status'] as String?) ?? 'pending',
      startAt: json['start_at'] != null
          ? DateTime.tryParse(json['start_at'] as String)
          : null,
      endAt: json['end_at'] != null
          ? DateTime.tryParse(json['end_at'] as String)
          : null,
      dueAt: json['due_at'] != null
          ? DateTime.tryParse(json['due_at'] as String)
          : null,
      isAllDay: (json['is_all_day'] as bool?) ?? false,
      source: (json['source'] as String?) ?? 'manual',
      externalProvider: json['external_provider'] as String?,
      externalId: json['external_id'] as String?,
      notifyBeforeMinutes:
          (json['notify_before_minutes'] as num?)?.toInt(),
      notifyEnabled: (json['notify_enabled'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'rule_id': ruleId,
        'title': title,
        'description': description,
        'kind': kind,
        'status': status,
        'start_at': startAt?.toIso8601String(),
        'end_at': endAt?.toIso8601String(),
        'due_at': dueAt?.toIso8601String(),
        'is_all_day': isAllDay,
        'source': source,
        'external_provider': externalProvider,
        'external_id': externalId,
        'notify_before_minutes': notifyBeforeMinutes,
        'notify_enabled': notifyEnabled,
      };

  ScheduleItem copyWith({String? status}) {
    return ScheduleItem(
      id: id,
      userId: userId,
      ruleId: ruleId,
      title: title,
      description: description,
      kind: kind,
      status: status ?? this.status,
      startAt: startAt,
      endAt: endAt,
      dueAt: dueAt,
      isAllDay: isAllDay,
      source: source,
      externalProvider: externalProvider,
      externalId: externalId,
      notifyBeforeMinutes: notifyBeforeMinutes,
      notifyEnabled: notifyEnabled,
    );
  }
}
