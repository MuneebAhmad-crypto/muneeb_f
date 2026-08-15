import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';

import '../../../common/tools.dart';
import '../config/image_compare_config.dart';

class ImageCompareLayout extends StatefulWidget {
  final ImageCompareConfig config;

  const ImageCompareLayout({required this.config, super.key});

  @override
  State<ImageCompareLayout> createState() => _ImageCompareLayoutState();
}

class _ImageCompareLayoutState extends State<ImageCompareLayout> {
  double _value = 0.5;
  late Widget _beforeImage;
  late Widget _afterImage;

  Color? get _trackColor {
    final trackColor = widget.config.trackColor;
    if (trackColor == null || trackColor.isEmpty) {
      return null;
    }

    try {
      return HexColor(trackColor);
    } catch (_) {
      return null;
    }
  }

  Widget _buildImage(String imageUrl) {
    return RepaintBoundary(
      child: FluxImage(imageUrl: imageUrl, fit: BoxFit.cover),
    );
  }

  @override
  void initState() {
    super.initState();
    _beforeImage = _buildImage(widget.config.beforeImage);
    _afterImage = _buildImage(widget.config.afterImage);
  }

  @override
  void didUpdateWidget(covariant ImageCompareLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.beforeImage != widget.config.beforeImage) {
      _beforeImage = _buildImage(widget.config.beforeImage);
    }
    if (oldWidget.config.afterImage != widget.config.afterImage) {
      _afterImage = _buildImage(widget.config.afterImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    if (config.beforeImage.isEmpty || config.afterImage.isEmpty) {
      return const SizedBox();
    }

    final width = config.width ?? MediaQuery.sizeOf(context).width;

    Widget child = BeforeAfter(
      before: _beforeImage,
      after: _afterImage,
      width: width,
      height: config.height,
      trackWidth: config.trackWidth,
      trackColor: _trackColor,
      thumbColor: _trackColor,
      value: _value,
      onValueChanged: (value) => setState(() => _value = value),
    );

    if (config.borderRadius > 0) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: child,
      );
    }

    if (config.padding > 0) {
      child = Padding(padding: EdgeInsets.all(config.padding), child: child);
    }

    return child;
  }
}
