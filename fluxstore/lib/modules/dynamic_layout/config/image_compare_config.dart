import '../helper/helper.dart';

const _undefined = Object();

class ImageCompareConfig {
  /// URL for the image shown on the "before" side of the comparison.
  final String beforeImage;

  /// URL for the image shown on the "after" side of the comparison.
  final String afterImage;

  /// Allows a nullable width value; the layout widget applies the fallback.
  final double? width;

  /// Optional explicit layout height from JSON.
  final double? height;

  /// Optional custom width for the compare track.
  final double? trackWidth;

  /// Optional hex color for the compare track.
  final String? trackColor;

  /// Border radius applied to the comparison widget.
  final double borderRadius;

  /// Padding around the images.
  final double padding;

  ImageCompareConfig({
    this.beforeImage = '',
    this.afterImage = '',
    this.width,
    this.height,
    this.trackWidth,
    this.trackColor,
    this.borderRadius = 0.0,
    this.padding = 0.0,
  });

  factory ImageCompareConfig.fromJson(Map<String, dynamic> json) {
    return ImageCompareConfig(
      beforeImage: json['beforeImage'] ?? '',
      afterImage: json['afterImage'] ?? '',
      width: Helper.formatDouble(json['width']),
      height: Helper.formatDouble(json['height']),
      trackWidth: Helper.formatDouble(json['trackWidth']),
      trackColor: json['trackColor'],
      borderRadius: Helper.formatDouble(json['borderRadius']) ?? 0.0,
      padding: Helper.formatDouble(json['padding']) ?? 0.0,
    );
  }

  ImageCompareConfig copyWith({
    String? beforeImage,
    String? afterImage,
    Object? width = _undefined,
    Object? height = _undefined,
    Object? trackWidth = _undefined,
    Object? trackColor = _undefined,
    double? borderRadius,
    double? padding,
  }) {
    return ImageCompareConfig(
      beforeImage: beforeImage ?? this.beforeImage,
      afterImage: afterImage ?? this.afterImage,
      width: identical(width, _undefined) ? this.width : width as double?,
      height: identical(height, _undefined) ? this.height : height as double?,
      trackWidth: identical(trackWidth, _undefined)
          ? this.trackWidth
          : trackWidth as double?,
      trackColor: identical(trackColor, _undefined)
          ? this.trackColor
          : trackColor as String?,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['beforeImage'] = beforeImage;
    map['afterImage'] = afterImage;
    map['width'] = width;
    map['height'] = height;
    map['trackWidth'] = trackWidth;
    map['trackColor'] = trackColor;
    map['borderRadius'] = borderRadius;
    map['padding'] = padding;
    return map;
  }
}
