import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wishlist_controller.dart';

class WishlistIcon extends StatefulWidget {
  const WishlistIcon({
    required this.type,
    required this.itemId,
    this.initiallyWishlisted = false,
    this.size = 16,
    this.color = const Color(0xFFFF7A2F),
    super.key,
  });

  final String type;
  final String itemId;
  final bool initiallyWishlisted;
  final double size;
  final Color color;

  @override
  State<WishlistIcon> createState() => _WishlistIconState();
}

class _WishlistIconState extends State<WishlistIcon> {
  late final WishlistController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<WishlistController>();
    _scheduleSeedInitialWishlistState();
  }

  @override
  void didUpdateWidget(covariant WishlistIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool becameInitiallyWishlisted =
        !oldWidget.initiallyWishlisted && widget.initiallyWishlisted;
    final bool identityChanged =
        oldWidget.type != widget.type || oldWidget.itemId != widget.itemId;

    if (becameInitiallyWishlisted || identityChanged) {
      _scheduleSeedInitialWishlistState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String normalizedType = widget.type.trim().toLowerCase();
    final String normalizedId = widget.itemId.trim();
    if (normalizedType.isEmpty || normalizedId.isEmpty) {
      return Icon(
        Icons.favorite_border,
        color: widget.color,
        size: widget.size,
      );
    }

    return Obx(() {
      final bool isWishlisted = _controller.isWishlisted(
        normalizedType,
        normalizedId,
      );
      final bool isBusy = _controller.isToggling(normalizedType, normalizedId);

      return IgnorePointer(
        ignoring: isBusy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _controller.toggleWishlist(
            type: normalizedType,
            itemId: normalizedId,
          ),
          child: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: widget.color,
            size: widget.size,
          ),
        ),
      );
    });
  }

  void _scheduleSeedInitialWishlistState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _seedInitialWishlistState();
    });
  }

  void _seedInitialWishlistState() {
    final String normalizedType = widget.type.trim().toLowerCase();
    final String normalizedId = widget.itemId.trim();
    if (normalizedType.isEmpty || normalizedId.isEmpty) {
      return;
    }

    _controller.seedWishlist(
      type: normalizedType,
      itemId: normalizedId,
      isWishlisted: widget.initiallyWishlisted,
    );
  }
}
