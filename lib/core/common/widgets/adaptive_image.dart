import 'package:flutter/material.dart';

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
    if (_isNetwork) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
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
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE8E8E8),
    );
  }
}
