import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flux_interface/flux_interface.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:fstore/common/constants.dart';
import 'package:fstore/models/entities/index.dart';
import 'package:fstore/services/notification/notification_service.dart';

const _topicAll = 'all-notifications';

class FirebaseNotificationServiceImpl extends FirebaseNotificationService {
  final _instance = FirebaseMessaging.instance;
  final _handledForegroundMessages = <String>{};

  StreamSubscription? _notificationSubscription;

  // @override
  // Future<bool> requestPermission() async {
  //   try {
  //     final result = await _instance.requestPermission();
  //     return result.alert == AppleNotificationSetting.enabled;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  @override
  Future<void> init({
    required NotificationDelegate notificationDelegate,
  }) async {
    if (isInitialized) {
      return;
    }
    setIsInitialized();
    delegate = notificationDelegate;
    if (isNotificationEnabled()) {
      await enableNotification();
    } else {
      await disableNotification();
    }

    await _instance
        .getInitialMessage()
        .then((initMessage) {
          if (initMessage != null) {
            delegate.onMessageOpenedApp(_toNotificationItem(initMessage));
          }
        })
        .catchError((err) {
          printLog('[FirebaseCloudMessaging] getInitialMessage error: $err');
          return null;
        });

    _notificationSubscription = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      // Don't process notification if notifications are disabled in app settings
      if (!isNotificationEnabled()) {
        return;
      }

      final item = _toNotificationItem(message);

      if (_isHandledMessage(item.id)) {
        return;
      }

      if (isAndroid && (item.title.isNotEmpty || item.body.isNotEmpty)) {
        final imageUrl = _resolveImageUrl(message, message.data);
        await showForegroundNotification(
          id: buildNotificationId(item),
          title: item.title,
          body: item.body,
          smallIcon: message.notification?.android?.smallIcon,
          bigPictureUrl: imageUrl,
          largeIconUrl: imageUrl,
          payload: jsonEncode(item.toJson()),
        );
      }

      final hasAdditionalData = item.additionalData?.isNotEmpty == true;
      if (item.title.isNotEmpty || item.body.isNotEmpty || hasAdditionalData) {
        delegate.onMessage(item);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Process notification tap regardless of enable status
      // (user already opened the notification)
      delegate.onMessageOpenedApp(_toNotificationItem(message));
    });
  }

  @override
  Future<void> disableNotification() async {
    try {
      if (!kIsWeb) {
        await _instance.unsubscribeFromTopic(_topicAll);
      }

      // Hard opt-out: prevent new token generation and invalidate current token.
      await _instance.setAutoInitEnabled(false);
      await _instance.deleteToken();
    } catch (err) {
      printLog('[FirebaseCloudMessaging] disableNotification error: $err');
    }

    await _instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    _notificationSubscription?.pause();
  }

  @override
  Future<void> enableNotification() async {
    try {
      await _instance.setAutoInitEnabled(true);
      await _instance
          .getToken()
          .then((token) {
            if (token != null) {
              printLog('[FirebaseCloudMessaging] obtained FCM token: $token');
            } else {
              printLog('[FirebaseCloudMessaging] failed to obtain FCM token');
            }
            return token;
          })
          .catchError((err) {
            printLog('[FirebaseCloudMessaging] getToken error: $err');
            return null;
          });

      if (!kIsWeb) {
        await _instance.subscribeToTopic(_topicAll);
      }
    } catch (err) {
      printLog('[FirebaseCloudMessaging] enableNotification error: $err');
    }

    await _instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _notificationSubscription?.resume();
  }

  @override
  void setUserData({String? userId, String? email, String? phoneNumber}) {}

  @override
  void removeExternalId() {}

  FStoreNotificationItem _toNotificationItem(RemoteMessage message) {
    final notification = message.notification;
    final additionalData = _normalizedAdditionalData(message);
    final title =
        notification?.title ??
        additionalData['title']?.toString() ??
        additionalData['notification_title']?.toString() ??
        '';
    final body =
        notification?.body ??
        additionalData['body']?.toString() ??
        additionalData['message']?.toString() ??
        '';

    return FStoreNotificationItem(
      id: _resolveMessageId(message),
      title: title,
      body: body,
      additionalData: additionalData,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> _normalizedAdditionalData(RemoteMessage message) {
    final additionalData = Map<String, dynamic>.from(message.data);
    final image = _resolveImageUrl(message, additionalData);

    if (image != null && image.isNotEmpty) {
      additionalData.putIfAbsent('image', () => image);
      additionalData.putIfAbsent('image_url', () => image);
    }

    return additionalData;
  }

  String? _resolveImageUrl(RemoteMessage message, Map<String, dynamic> data) {
    final androidNotification = message.notification?.android;
    final appleNotification = message.notification?.apple;
    final webNotification = message.notification?.web;

    final candidates = <dynamic>[
      data['image'],
      data['image_url'],
      data['imageUrl'],
      data['big_picture'],
      data['bigPicture'],
      androidNotification?.imageUrl,
      appleNotification?.imageUrl,
      webNotification?.image,
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  String _resolveMessageId(RemoteMessage message) {
    if (message.messageId?.isNotEmpty ?? false) {
      return message.messageId!;
    }
    final sentAt = message.sentTime?.millisecondsSinceEpoch ?? 0;
    final title =
        message.notification?.title ?? message.data['title']?.toString() ?? '';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';
    return '$sentAt-$title-$body';
  }

  bool _isHandledMessage(String id) {
    if (id.isEmpty) {
      return false;
    }

    if (_handledForegroundMessages.contains(id)) {
      return true;
    }

    if (_handledForegroundMessages.length >= 100) {
      _handledForegroundMessages.remove(_handledForegroundMessages.first);
    }
    _handledForegroundMessages.add(id);
    return false;
  }
}
