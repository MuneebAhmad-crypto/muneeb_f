import 'dart:convert';

import '../../common/constants.dart';

class FStoreNotificationItem {
  final String id;
  final String title;
  final String body;
  final bool seen;
  final Map? additionalData;
  final DateTime? date;

  const FStoreNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.additionalData,
    this.seen = false,
    required this.date,
  });

  String get displayDate {
    final date = this.date;
    if (date == null) return '';
    // final dateDiff = DateTime.now().difference(date);
    return date.timeAgo();
  }

  String? get dynamicLink => _firstNonEmptyDynamicLink(additionalData, const [
    'dynamic_link',
    'dynamicLink',
    'launch_url',
    'launchUrl',
    'url',
    'deep_link',
    'deeplink',
    'link',
    'u',
  ]);

  String? get image {
    final image = _firstNonEmptyString(additionalData, const [
      'image',
      'image_url',
      'imageUrl',
      'big_picture',
      'bigPicture',
      'notification_image',
      'picture',
    ]);
    if (image != null) {
      return image;
    }

    return _findFirstImageInNestedData(additionalData);
  }

  static String? _firstNonEmptyString(Map? map, List<String> keys) {
    if (map == null) {
      return null;
    }

    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final lowerCaseEntries = <String, dynamic>{};
    map.forEach((key, value) {
      if (key is String) {
        lowerCaseEntries[key.toLowerCase()] = value;
      }
    });

    for (final key in keys) {
      final value = lowerCaseEntries[key.toLowerCase()];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  static String? _firstNonEmptyDynamicLink(Map? map, List<String> keys) {
    final direct = _firstNonEmptyString(map, keys);
    if (_isValidDynamicLink(direct)) {
      return direct;
    }

    if (map == null) {
      return null;
    }

    final normalizedMap = <String, dynamic>{};
    map.forEach((key, value) {
      normalizedMap[key.toString().toLowerCase()] = value;
    });

    for (final key in keys) {
      final nested = _extractDynamicLink(normalizedMap[key.toLowerCase()]);
      if (nested != null) {
        return nested;
      }
    }

    const preferredNestedKeys = ['custom', 'a', 'data', 'raw_payload'];
    for (final key in preferredNestedKeys) {
      final nested = _extractDynamicLink(normalizedMap[key]);
      if (nested != null) {
        return nested;
      }
    }

    for (final value in normalizedMap.values) {
      final nested = _extractDynamicLink(value);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  static String? _extractDynamicLink(dynamic value) {
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return null;
      }

      if (_isValidDynamicLink(normalized)) {
        return normalized;
      }

      final decoded = _tryDecodeJsonString(normalized);
      if (decoded != null) {
        return _extractDynamicLink(decoded);
      }

      return null;
    }

    if (value is Map) {
      final normalizedMap = <String, dynamic>{};
      value.forEach((key, mapValue) {
        normalizedMap[key.toString()] = mapValue;
      });

      return _firstNonEmptyDynamicLink(normalizedMap, const [
        'dynamic_link',
        'dynamicLink',
        'launch_url',
        'launchUrl',
        'url',
        'deep_link',
        'deeplink',
        'link',
        'u',
      ]);
    }

    if (value is Iterable) {
      for (final item in value) {
        final nested = _extractDynamicLink(item);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  static dynamic _tryDecodeJsonString(String value) {
    final startsAsJson =
        value.startsWith('{') || value.startsWith('[') || value.startsWith('"');
    if (!startsAsJson) {
      return null;
    }

    try {
      return jsonDecode(value);
    } catch (_) {
      return null;
    }
  }

  static bool _isValidDynamicLink(String? value) {
    if (value == null || value.trim().isEmpty) {
      return false;
    }

    final normalized = value.trim().toLowerCase();
    if (!(normalized.startsWith('http://') ||
        normalized.startsWith('https://'))) {
      return false;
    }

    return !(normalized.contains('.png') ||
        normalized.contains('.jpg') ||
        normalized.contains('.jpeg') ||
        normalized.contains('.webp') ||
        normalized.contains('.gif') ||
        normalized.contains('.heic'));
  }

  static String? _findFirstImageInNestedData(dynamic value) {
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      final isImageUrl =
          normalized.startsWith('http') &&
          (normalized.contains('.png') ||
              normalized.contains('.jpg') ||
              normalized.contains('.jpeg') ||
              normalized.contains('.webp') ||
              normalized.contains('.gif') ||
              normalized.contains('.heic') ||
              normalized.contains('/image'));
      if (isImageUrl) {
        return value.trim();
      }
      return null;
    }

    if (value is Map) {
      final mapped = Map<String, dynamic>.from(
        value.map((key, value) => MapEntry(key.toString(), value)),
      );

      final direct = _firstNonEmptyString(mapped, const [
        'image',
        'url',
        'src',
        'href',
        'image_url',
        'imageUrl',
      ]);
      if (direct != null) {
        return direct;
      }

      for (final entry in mapped.entries) {
        final nested = _findFirstImageInNestedData(entry.value);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    if (value is Iterable) {
      for (final item in value) {
        final nested = _findFirstImageInNestedData(item);
        if (nested != null) {
          return nested;
        }
      }
    }

    return null;
  }

  factory FStoreNotificationItem.fromJson(Map json) {
    return FStoreNotificationItem(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      seen: json['seen'],
      additionalData: json['additionalData'],
      date: DateTime.tryParse(json['date']),
    );
  }

  FStoreNotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    bool? seen,
    Map? additionalData,
    DateTime? date,
  }) {
    return FStoreNotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      seen: seen ?? this.seen,
      body: body ?? this.body,
      additionalData: Map<String, dynamic>.from(
        jsonDecode(jsonEncode(additionalData ?? this.additionalData ?? {})),
      ),
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('id', id);
    writeNotNull('title', title);
    writeNotNull('body', body);
    writeNotNull('seen', seen);
    writeNotNull('additionalData', additionalData);
    writeNotNull('date', date.toString());
    return val;
  }
}
