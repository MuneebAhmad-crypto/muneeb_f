import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../common/constants.dart';
import '../data/boxes.dart';
import '../dependency_injection/dependency_injection.dart';
import '../services/notification/notification_service.dart';
import '../services/services.dart';
import 'entities/fstore_notification.dart';
import 'entities/fstore_notification_item.dart';

class NotificationModel extends ChangeNotifier {
  final _service = injector<NotificationService>();
  FStoreNotification _fStoreNotification = FStoreNotification.init(true);

  bool get enable => _fStoreNotification.enable;

  UnmodifiableListView<FStoreNotificationItem> get listNotification =>
      UnmodifiableListView(_fStoreNotification.listNotification);

  int get unreadCount =>
      _fStoreNotification.listNotification.where((item) => !item.seen).length;

  NotificationModel() {
    _loadDataFromLocal();
    // Set callback so notification service can check if notifications are enabled
    // This prevents showing notifications when user has disabled them
    _service.setIsNotificationEnabledCallback(() => _fStoreNotification.enable);

    unawaited(_syncWithSystemPermission());
  }

  void _loadDataFromLocal() {
    final data = UserBox().notification;
    if (data != null) {
      _fStoreNotification = data;
    }
  }

  Future<void> _syncWithSystemPermission() async {
    if (!(await _service.isGranted())) {
      await disableNotification();
    }
  }

  void markAsRead(String notificationId) {
    _setStatusMessage(notificationId: notificationId, seen: true);
  }

  void markAsUnread(String notificationId) {
    _setStatusMessage(notificationId: notificationId, seen: false);
  }

  void removeMessage(String notificationId) {
    final notifications = _fStoreNotification.listNotification;
    notifications.removeWhere((element) => element.id == notificationId);
    _fStoreNotification.copyWith(listNotification: notifications);
    notifyListeners();
    _saveDataToLocal();
  }

  void removeAllMessages() {
    _fStoreNotification = _fStoreNotification.copyWith(listNotification: []);
    notifyListeners();
    _saveDataToLocal();
  }

  void saveMessage(FStoreNotificationItem item) {
    final normalizedItem = item.id.isNotEmpty
        ? item
        : item.copyWith(id: _buildFallbackId(item));
    final notifications = _fStoreNotification.listNotification;
    final isExist = notifications.any(
      (element) => element.id == normalizedItem.id,
    );
    if (isExist) return;
    notifications.add(normalizedItem);
    _fStoreNotification = _fStoreNotification.copyWith(
      listNotification: notifications,
    );
    notifyListeners();
    _saveDataToLocal();
  }

  Future<void> checkGranted() async {
    final isGranted = await _service.isGranted();
    // Never auto-enable when user explicitly disabled notifications.
    if (!isGranted && enable) {
      await disableNotification();
    }
  }

  Future<bool> enableNotification() async {
    if (!(await _service.isGranted())) {
      final granted = await _service.requestPermission();
      if (!granted) {
        return false;
      }
    }
    _fStoreNotification = _fStoreNotification.copyWith(enable: true);
    await _service.enableNotification();
    notifyListeners();
    unawaited(_saveDataToLocal());
    unawaited(_syncDeviceToken(UserBox().userCookie));
    return true;
  }

  Future<void> disableNotification() async {
    _fStoreNotification = _fStoreNotification.copyWith(enable: false);
    await _service.disableNotification();
    await _saveDataToLocal();
    notifyListeners();
    unawaited(_syncDeviceToken(UserBox().userCookie));
  }

  void _setStatusMessage({required String notificationId, required bool seen}) {
    final notifications = _fStoreNotification.listNotification;
    var index = notifications.indexWhere(
      (element) => element.id == notificationId,
    );
    final item = notifications[index];
    notifications[index] = item.copyWith(seen: seen);
    _fStoreNotification = _fStoreNotification.copyWith(
      listNotification: notifications,
    );
    notifyListeners();
    _saveDataToLocal();
  }

  Future<void> _saveDataToLocal() async {
    UserBox().notification = _fStoreNotification;
  }

  String _buildFallbackId(FStoreNotificationItem item) {
    final sentAt =
        item.date?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;
    return '$sentAt-${item.title}-${item.body}'.hashCode.toString();
  }

  void updateNotificationStatus(String? cookie) {
    unawaited(
      Services().api.enableNotification(
        cookie: cookie,
        enabled: _fStoreNotification.enable,
      ),
    );

    unawaited(_syncDeviceToken(cookie));
  }

  Future<void> _syncDeviceToken(String? cookie) async {
    if (!Services().firebase.isEnabled || cookie == null || cookie.isEmpty) {
      return;
    }

    try {
      final deviceToken = _fStoreNotification.enable
          ? await _getMessagingTokenWithRetry() ?? ''
          : '';

      await Services().api.updateUserInfo({'deviceToken': deviceToken}, cookie);
    } catch (err) {
      printLog('[NotificationModel] sync device token error: $err');
    }
  }

  Future<String?> _getMessagingTokenWithRetry() async {
    for (var i = 0; i < 3; i++) {
      final token = await Services().firebase.getMessagingToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }

      if (i < 2) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    return null;
  }
}
