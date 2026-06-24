import 'package:flutter/material.dart';

import '../constants/app_images.dart';

class AdaptiveImage extends StatelessWidget {
  const AdaptiveImage({
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isNetwork {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (path.trim().isEmpty) {
      return _placeholder();
    }

    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int? cacheWidth = _resolveCacheSize(width, devicePixelRatio);
    final int? cacheHeight = _resolveCacheSize(height, devicePixelRatio);

    if (_isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        filterQuality: FilterQuality.low,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholder();
        },
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      filterQuality: FilterQuality.low,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  int? _resolveCacheSize(double? logicalSize, double pixelRatio) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final double scaled = logicalSize * pixelRatio;
    if (!scaled.isFinite || scaled <= 0) {
      return null;
    }
    return scaled.round();
  }

  Widget _placeholder() {
    return Image.asset(
      AppImages.restaurantPlaceholder,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        color: const Color(0xFFE8E8E8),
      ),
    );
  }
}
