import 'notification_service.dart';

class NotificationServiceImpl extends NotificationService {
  @override
  Future<void> disableNotification() async {}

  @override
  Future<void> enableNotification() async {}

  @override
  void init({required NotificationDelegate notificationDelegate}) {}

  @override
  void setUserData({String? userId, String? email, String? phoneNumber}) {}

  @override
  void removeExternalId() {}
}
