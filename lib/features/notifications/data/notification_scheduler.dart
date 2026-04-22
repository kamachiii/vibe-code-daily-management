import 'package:smart_planner/features/notifications/data/local_notifications_service.dart';
import 'package:smart_planner/features/schedules/domain/schedule_item.dart';

/// Reconciles local notifications against the current list of [ScheduleItem]s.
///
/// Call [reconcile] after any schedule change or on app foreground.
/// The scheduler is idempotent: safe to call multiple times.
class NotificationScheduler {
  NotificationScheduler(this._notifications);

  final LocalNotificationsService _notifications;

  /// Cancel all existing notifications and re-schedule from [items].
  Future<void> reconcile(List<ScheduleItem> items) async {
    await _notifications.cancelAll();

    for (final item in items) {
      if (!item.notifyEnabled) continue;

      final trigger = _triggerTime(item);
      if (trigger == null) continue;
      if (trigger.isBefore(DateTime.now())) continue;

      // Use a deterministic int ID derived from the item's UUID.
      final notifId = item.id.hashCode.abs() % (1 << 31);

      await _notifications.scheduleNotification(
        id: notifId,
        title: item.title,
        body: item.description ?? 'You have an upcoming event.',
        scheduledDate: trigger,
      );
    }
  }

  DateTime? _triggerTime(ScheduleItem item) {
    final reference = item.startAt ?? item.dueAt;
    if (reference == null) return null;

    final offsetMinutes = item.notifyBeforeMinutes ?? 15;
    return reference.subtract(Duration(minutes: offsetMinutes));
  }
}
