import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AppNotifier {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showFineAlert(int amount) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fine_alerts_channel',
      'Fine Alerts',
      channelDescription: 'Notifications for seat reservation fines',
      importance: Importance.max,
      priority: Priority.high,
      colorized: true,
      color: Color(0xFFBA1A1A),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      'Fine Alert!',
      'A fine of Rs. $amount has been added to your account for missing your reservation.',
      notificationDetails,
    );
  }
}
