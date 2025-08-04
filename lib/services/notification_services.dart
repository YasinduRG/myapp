import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  // static Future<void> showScheduledNotification({
  //   required String title,
  //   required String body,
  // }) async {
  //   await _notificationsPlugin.zonedSchedule(
  //     1, // Use a different ID for this notification (e.g., 1)
  //     title,
  //     body,
  //     // Schedule it 1 minute from now
  //     tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'DPMC-Invoice-System-Scheduled', // A unique ID for the scheduled channel
  //         'Scheduled Notification Channel',
  //         channelDescription: 'DPMC Invoice System Scheduled Notifications',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //     // Make sure to match the Android UI time with the scheduled time.
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     androidAllowWhileIdle:
  //         true, // Allow notification to appear even when the device is in a low-power idle mode.
  //   );
  // }
}
