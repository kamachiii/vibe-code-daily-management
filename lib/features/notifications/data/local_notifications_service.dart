import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wrapper around [FlutterLocalNotificationsPlugin].
///
/// Call [initialize] once at startup (before showing any notification).
class LocalNotificationsService {
  LocalNotificationsService()
      : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  /// Schedules a one-time notification at [scheduledDate].
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // TODO: implement scheduling with TZDateTime once timezone package is added.
    // Placeholder: show an immediate notification instead.
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'smart_planner_channel',
          'Smart Planner',
          channelDescription: 'Schedule reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// Cancels a previously scheduled notification by [id].
  Future<void> cancel(int id) => _plugin.cancel(id);

  /// Cancels all pending notifications.
  Future<void> cancelAll() => _plugin.cancelAll();
}
