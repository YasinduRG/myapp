import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz; // Import timezone

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'DPMC-Invoice-System',
          'Notification Channel',
          channelDescription: 'DPMC Invoice System',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // --- NEW: METHOD FOR SCHEDULED NOTIFICATIONS ---
  static Future<void> showScheduledNotification({
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      1, // Use a different ID for this notification
      title,
      body,
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'DPMC-Invoice-System',
          'Notification Channel',
          channelDescription: 'DPMC Invoice System',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // --- ADD THIS REQUIRED PARAMETER ---
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
