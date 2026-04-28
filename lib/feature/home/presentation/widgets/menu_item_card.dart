import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/theme/app_colors.dart';

class MenuItemCard extends StatefulWidget {
  const MenuItemCard({
    super.key,
    required this.isSpecialOffer,
    this.imagePath = AppImages.food,
    this.dishName = 'Signature Avocad...',
    this.priceText = '\$18.90',
    this.subtitle = 'Sourdough, poached eggs...',
    this.offerLabel,
    this.onEditTap,
    this.onOfferToggle,
  });

  final bool isSpecialOffer;
  final String imagePath;
  final String dishName;
  final String priceText;
  final String subtitle;
  final String? offerLabel;
  final VoidCallback? onEditTap;
  final Future<bool> Function(bool value)? onOfferToggle;

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  late bool _isSpecialOffer;

  @override
  void initState() {
    super.initState();
    _isSpecialOffer = widget.isSpecialOffer;
  }

  @override
  void didUpdateWidget(covariant MenuItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSpecialOffer != widget.isSpecialOffer) {
      _isSpecialOffer = widget.isSpecialOffer;
    }
  }

  Future<void> _handleToggle() async {
    final bool nextValue = !_isSpecialOffer;

    if (widget.onOfferToggle == null) {
      setState(() {
        _isSpecialOffer = nextValue;
      });
      return;
    }

    setState(() {
      _isSpecialOffer = nextValue;
    });

    final bool success = await widget.onOfferToggle!(nextValue);
    if (!mounted || success) return;

    setState(() {
      _isSpecialOffer = !nextValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AdaptiveImage(
              path: widget.imagePath,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.dishName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.priceText,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: _handleToggle,
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: 52,
                        height: 30,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _isSpecialOffer
                              ? AppColors.primaryGreen
                              : const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Align(
                          alignment: _isSpecialOffer
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.offerLabel ??
                          (_isSpecialOffer ? 'Special Offer' : 'Regular'),
                      style: TextStyle(
                        color: _isSpecialOffer
                            ? AppColors.primaryGreen
                            : AppColors.textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: widget.onEditTap,
                      child: Image.asset(
                        AppImages.editfood,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
