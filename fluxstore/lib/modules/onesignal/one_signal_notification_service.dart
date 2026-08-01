import 'dart:convert';

import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../common/constants.dart';
import '../../data/boxes.dart';
import '../../models/entities/fstore_notification_item.dart';
import '../../services/notification/notification_service.dart';

class OneSignalNotificationService extends NotificationService {
  static final _iso6391LanguageCodeRegex = RegExp(r'^[a-z]{2}$');
  final _oneSignalUser = OneSignal.User;
  final _oneSignalNotification = OneSignal.Notifications;
  final String appID;
  final _handledForegroundMessages = <String>{};

  OneSignalNotificationService({required this.appID}) {
    OneSignal.initialize(appID);
  }

  @override
  Future<void> disableNotification() async {
    await _oneSignalUser.pushSubscription.optOut();
  }

  @override
  Future<void> enableNotification() async {
    await _oneSignalUser.pushSubscription.optIn();
  }

  @override
  void init({required NotificationDelegate notificationDelegate}) {
    if (isInitialized) {
      return;
    }
    setIsInitialized();
    delegate = notificationDelegate;

    _setupOnMessageOpenedApp();
    _setupOnMessage();

    // Sync language with OneSignal
    final langCode = SettingsBox().languageCode;

    _changeLanguage(langCode);

    eventBus.on<EventChangeLanguage>().listen((event) {
      final langCode = SettingsBox().languageCode;

      _changeLanguage(langCode);
    });
  }

  void _changeLanguage(String? languageCode) {
    final iso6391LanguageCode = _toIso6391LanguageCode(languageCode);
    if (iso6391LanguageCode != null) {
      OneSignal.User.setLanguage(iso6391LanguageCode);
    }
  }

  String? _toIso6391LanguageCode(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    final normalizedLanguageCode = languageCode
        .replaceAll('-', '_')
        .split('_')
        .first
        .toLowerCase();

    if (!_iso6391LanguageCodeRegex.hasMatch(normalizedLanguageCode)) {
      return null;
    }

    return normalizedLanguageCode;
  }

  void _setupOnMessage() {
    _oneSignalNotification.addForegroundWillDisplayListener(_onMessage);
  }

  void _onMessage(OSNotificationWillDisplayEvent result) async {
    // Prevent OneSignal's native display so we can render our own local
    // notification (heads-up banner, big-picture image, deep-link payload).
    //
    // IMPORTANT: call preventDefault() SYNCHRONOUSLY here, before the first
    // `await`. The OneSignal SDK runs this listener and then sends
    // `proceedWithWillDisplay` to the native side. Calling preventDefault()
    // before any await guarantees it is queued on the OneSignal method channel
    // BEFORE `proceedWithWillDisplay`, so native knows not to display its own
    // notification. If we awaited first, ordering could break and the
    // notification would be suppressed after a 30s native timeout.
    result.preventDefault();

    // If notifications are disabled in app settings, show nothing.
    if (!isNotificationEnabled()) {
      return;
    }

    final data = result.notification;
    final item = _toNotificationItem(data);

    // Skip if this notification was already handled.
    if (_isHandledMessage(item.id)) {
      return;
    }

    // Show a local notification to guarantee the heads-up banner + image.
    if (item.title.isNotEmpty || item.body.isNotEmpty) {
      await showForegroundNotification(
        id: buildNotificationId(item),
        title: item.title,
        body: item.body,
        bigPictureUrl: item.image,
        largeIconUrl: data.largeIcon,
        payload: jsonEncode(_buildForegroundTapPayload(item)),
      );
    }

    // Update the in-app notification list/badge.
    if (item.title.isNotEmpty ||
        item.body.isNotEmpty ||
        item.additionalData != null) {
      delegate.onMessage(item);
    }
  }

  void _setupOnMessageOpenedApp() {
    _oneSignalNotification.addClickListener((OSNotificationClickEvent result) {
      result.preventDefault();
      final data = result.notification;
      delegate.onMessageOpenedApp(_toNotificationItem(data));
    });
  }

  FStoreNotificationItem _toNotificationItem(OSNotification data) {
    final additionalData = _normalizedAdditionalData(data);
    return FStoreNotificationItem(
      id: _resolveNotificationId(data),
      title: data.title ?? '',
      body: data.body ?? '',
      additionalData: additionalData,
      date: DateTime.now(),
    );
  }

  Map<String, dynamic> _buildForegroundTapPayload(FStoreNotificationItem item) {
    final additionalData = <String, dynamic>{};

    final dynamicLink = item.dynamicLink;
    if (dynamicLink != null && dynamicLink.isNotEmpty) {
      additionalData['dynamic_link'] = dynamicLink;
      additionalData['launch_url'] = dynamicLink;
      additionalData['url'] = dynamicLink;
    }

    final image = item.image;
    if (image != null && image.isNotEmpty) {
      additionalData['image'] = image;
    }

    final type = item.additionalData?['type'];
    if (type is String && type.isNotEmpty) {
      additionalData['type'] = type;
    }

    return {
      'id': item.id,
      'title': item.title,
      'body': item.body,
      'seen': item.seen,
      'additionalData': additionalData.isEmpty ? null : additionalData,
      'date': (item.date ?? DateTime.now()).toIso8601String(),
    };
  }

  String _resolveNotificationId(OSNotification data) {
    if (data.notificationId.isNotEmpty) {
      return data.notificationId;
    }
    final sentAt = DateTime.now().millisecondsSinceEpoch;
    final title = data.title ?? '';
    final body = data.body ?? '';
    return '$sentAt-$title-$body';
  }

  Map<String, dynamic>? _normalizedAdditionalData(OSNotification data) {
    final raw = data.additionalData;
    final mapped = raw is Map
        ? Map<String, dynamic>.from(
            raw!.map((key, value) => MapEntry(key.toString(), value)),
          )
        : <String, dynamic>{};

    if (data.launchUrl != null && data.launchUrl!.isNotEmpty) {
      mapped.putIfAbsent('launch_url', () => data.launchUrl);
      mapped.putIfAbsent('launchUrl', () => data.launchUrl);
      mapped.putIfAbsent('url', () => data.launchUrl);
    }

    if (data.attachments != null && data.attachments!.isNotEmpty) {
      mapped.putIfAbsent('ios_attachments', () => data.attachments);
      mapped.putIfAbsent('attachments', () => data.attachments);
    }

    if (data.rawPayload != null && data.rawPayload!.isNotEmpty) {
      mapped.putIfAbsent('raw_payload', () => data.rawPayload);
    }

    final dynamicLink = FStoreNotificationItem(
      id: '',
      title: '',
      body: '',
      additionalData: mapped,
      date: null,
    ).dynamicLink;
    if (dynamicLink != null && dynamicLink.isNotEmpty) {
      mapped['dynamic_link'] = dynamicLink;
      mapped.putIfAbsent('launch_url', () => dynamicLink);
      mapped.putIfAbsent('launchUrl', () => dynamicLink);
      mapped.putIfAbsent('url', () => dynamicLink);
    }

    final image = _resolveNotificationImage(data, mapped);
    if (image != null && image.isNotEmpty) {
      mapped.putIfAbsent('image', () => image);
      mapped.putIfAbsent('image_url', () => image);
    }

    if (mapped.isEmpty) {
      return null;
    }

    return mapped;
  }

  String? _resolveNotificationImage(
    OSNotification data,
    Map<String, dynamic> mapped,
  ) {
    final candidates = <dynamic>[
      mapped['image'],
      mapped['image_url'],
      mapped['imageUrl'],
      mapped['big_picture'],
      mapped['bigPicture'],
      mapped['ios_attachments'],
      mapped['attachments'],
      mapped['raw_payload'],
      data.attachments,
      data.rawPayload,
      data.bigPicture,
      // data.largeIcon,
      // data.smallIcon,
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }

      if (candidate is Map || candidate is Iterable) {
        final nested = _findImageFromDynamic(candidate);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  String? _findImageFromDynamic(dynamic value) {
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return null;
      }
      final lower = normalized.toLowerCase();
      if (lower.startsWith('http://') || lower.startsWith('https://')) {
        return normalized;
      }
      return null;
    }

    if (value is Map) {
      final normalizedMap = <String, dynamic>{};
      value.forEach((key, mapValue) {
        normalizedMap[key.toString().toLowerCase()] = mapValue;
      });

      const preferredKeys = [
        'image',
        'image_url',
        'imageurl',
        'big_picture',
        'bigpicture',
        'attachment',
        'attachment_url',
        'ios_attachments',
        'url',
        'src',
      ];

      for (final key in preferredKeys) {
        final direct = _findImageFromDynamic(normalizedMap[key]);
        if (direct != null) {
          return direct;
        }
      }

      for (final entry in normalizedMap.entries) {
        final nested = _findImageFromDynamic(entry.value);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    if (value is Iterable) {
      for (final item in value) {
        final nested = _findImageFromDynamic(item);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  @override
  void setUserData({String? userId, String? email, String? phoneNumber}) async {
    if (userId != null && userId.isNotEmpty) {
      // OneSignal blocks certain external IDs - must match backend list
      // Error: "Unable to create subscription: external_id is blocked, please use a different ID"
      // Add prefix only for restricted IDs to match backend logic

      final restrictedIds = [
        // Numeric values
        '0', '1', '-1',

        // Null variants
        'null', 'NULL',

        // Special values
        'NA', 'NaN',
        'UNQUALIFIED', 'all',

        // UUID empty
        '00000000-0000-0000-0000-000000000000',

        // Common placeholders
        '-', 'none', 'ok',
        '123ABC', 'unknown',
        'INVALID_USER', 'undefined', 'not set',
      ];

      final externalId = restrictedIds.contains(userId)
          ? 'user_$userId' // 1 → user_1,
          : userId; // 124 → 124 (unchanged)

      await OneSignal.login(externalId);
    }
    if (email != null && email.isNotEmpty) {
      await _oneSignalUser.addEmail(email);
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await _oneSignalUser.addSms(phoneNumber);
    }
  }

  @override
  void removeExternalId() async {
    await OneSignal.logout();
  }

  bool _isHandledMessage(String id) {
    if (id.isEmpty) {
      return false;
    }

    if (_handledForegroundMessages.contains(id)) {
      return true;
    }

    // Keep last 100 handled messages to avoid memory leak
    if (_handledForegroundMessages.length >= 100) {
      final oldestId = _handledForegroundMessages.first;
      _handledForegroundMessages.remove(oldestId);
    }

    _handledForegroundMessages.add(id);
    return false;
  }
}
