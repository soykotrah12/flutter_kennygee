import 'package:flutter/material.dart';

import '../../../../../core/common/constants/app_images.dart';
import '../../../../../core/common/widgets/adaptive_image.dart';
import '../../../../../core/theme/app_colors.dart';

class OwnerMapMarkerInfoCard extends StatelessWidget {
  const OwnerMapMarkerInfoCard({
    super.key,
    required this.shopName,
    required this.shopAddress,
    required this.shopImage,
  });

  final String shopName;
  final String shopAddress;
  final String shopImage;

  @override
  Widget build(BuildContext context) {
    final String resolvedImage = shopImage.trim().isEmpty
        ? AppImages.homeRestaurant1
        : shopImage;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 90),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.08, dark: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AdaptiveImage(
              path: resolvedImage,
              width: 66,
              height: 66,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shopName.trim().isEmpty ? 'My Restaurant' : shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shopAddress.trim().isEmpty
                      ? 'No address available'
                      : shopAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
