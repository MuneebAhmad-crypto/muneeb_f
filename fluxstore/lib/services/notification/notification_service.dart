import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../../models/entities/fstore_notification_item.dart';
import 'permissions/permission.dart';

abstract class NotificationService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  void setIsInitialized() {
    _isInitialized = true;
  }

  /// Callback to check if notifications are enabled in the app settings
  /// Used to prevent showing notifications when user has disabled them
  bool Function()? _isNotificationEnabledCallback;

  NotificationService() {
    unawaited(configureLocalNotificationTapHandler());

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  late final NotificationDelegate delegate;

  Future<void> configureLocalNotificationTapHandler() async {
    const initSetting = InitializationSettings(
      android: AndroidInitializationSettings(
        '@drawable/ic_stat_onesignal_default',
      ),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSetting,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    _handleNotificationPayload(response.payload);
  }

  static void _onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    // Background isolate cannot access app delegate. Foreground callback will
    // still run when app resumes.
  }

  void _handleNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) {
        return;
      }

      final notification = FStoreNotificationItem.fromJson(decoded);
      delegate.onMessageOpenedApp(notification);
    } catch (_) {
      // Ignore malformed payloads from non-app notifications.
    }
  }

  Future<void> showForegroundNotification({
    required int id,
    String? title,
    String? body,
    String? smallIcon,
    String? bigPictureUrl,
    String? largeIconUrl,
    String? payload,
  }) async {
    final bigPicture = await _loadAndroidBitmapFromUrl(bigPictureUrl);
    final largeIcon = await _loadAndroidBitmapFromUrl(largeIconUrl);
    final iosAttachmentPath = await _downloadImageToTempFilePath(bigPictureUrl);

    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      icon: smallIcon,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      largeIcon: largeIcon,
      styleInformation: bigPicture != null
          ? BigPictureStyleInformation(
              bigPicture,
              largeIcon: largeIcon,
              contentTitle: title,
              summaryText: body,
              hideExpandedLargeIcon: false,
            )
          : null,
    );

    await flutterLocalNotificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          attachments: iosAttachmentPath != null
              ? [DarwinNotificationAttachment(iosAttachmentPath)]
              : null,
        ),
      ),
      payload: payload,
    );
  }

  int buildNotificationId(FStoreNotificationItem item) {
    final timestamp = item.date?.millisecondsSinceEpoch ?? 0;
    final seed = item.id.isNotEmpty
        ? item.id
        : '$timestamp-${item.title}-${item.body}';
    return seed.hashCode & 0x7fffffff;
  }

  Future<ByteArrayAndroidBitmap?> _loadAndroidBitmapFromUrl(
    String? imageUrl,
  ) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    try {
      final uri = Uri.tryParse(imageUrl.trim());
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        return null;
      }

      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        return null;
      }

      return ByteArrayAndroidBitmap(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }

  Future<String?> _downloadImageToTempFilePath(String? imageUrl) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    try {
      final uri = Uri.tryParse(imageUrl.trim());
      if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
        return null;
      }

      final response = await http.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        return null;
      }

      final extension = _resolveImageExtension(uri.path);
      final fileName =
          'notification_${DateTime.now().microsecondsSinceEpoch}.$extension';
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  String _resolveImageExtension(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'png';
    }
    if (lower.endsWith('.gif')) {
      return 'gif';
    }
    if (lower.endsWith('.webp')) {
      return 'webp';
    }
    if (lower.endsWith('.heic')) {
      return 'heic';
    }
    if (lower.endsWith('.jpeg') || lower.endsWith('.jpg')) {
      return 'jpg';
    }
    return 'jpg';
  }

  void init({required NotificationDelegate notificationDelegate});

  Future<bool> requestPermission() async {
    return NotificationPermission.permission.requestPermission();
  }

  Future<bool> isGranted() async {
    return NotificationPermission.permission.isGranted();
  }

  /// Set a callback to check if notifications are enabled
  /// This prevents showing notifications when the user has disabled them in Settings
  void setIsNotificationEnabledCallback(bool Function() callback) {
    _isNotificationEnabledCallback = callback;
  }

  /// Check if notifications are currently enabled
  /// Returns true if no callback is set (default behavior)
  bool isNotificationEnabled() {
    return _isNotificationEnabledCallback?.call() ?? true;
  }

  Future<void> disableNotification();

  Future<void> enableNotification();

  void setUserData({String? userId, String? email, String? phoneNumber});

  void removeExternalId();
}

mixin NotificationDelegate {
  void onMessage(FStoreNotificationItem notification);

  void onMessageOpenedApp(FStoreNotificationItem notification);
}
