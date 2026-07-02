import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/google_nearby_restaurant_model.dart';

class GoogleNearbyRestaurantCard extends StatelessWidget {
  const GoogleNearbyRestaurantCard({
    required this.restaurant,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final GoogleNearbyRestaurantModel restaurant;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactGoogleRestaurantCard(restaurant: restaurant, onTap: onTap);
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double width = (screenWidth * 0.45).clamp(148.0, 200.0);

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AdaptiveImage(
                  path: restaurant.imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: _TitleRatingRow(restaurant: restaurant),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: _IconLabel(
                  asset: AppImages.location,
                  label: restaurant.distanceLabel,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: _IconLabel(
                  asset: AppImages.clock,
                  label: restaurant.openStatusLabel,
                  isStrong: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactGoogleRestaurantCard extends StatelessWidget {
  const _CompactGoogleRestaurantCard({required this.restaurant, this.onTap});

  final GoogleNearbyRestaurantModel restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AdaptiveImage(
                path: restaurant.imageUrl,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TitleRatingRow(restaurant: restaurant),
                  const SizedBox(height: 6),
                  _IconLabel(
                    asset: AppImages.location,
                    label: restaurant.distanceLabel,
                  ),
                  const SizedBox(height: 4),
                  _IconLabel(
                    asset: AppImages.clock,
                    label: restaurant.openStatusLabel,
                    isStrong: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.address.isEmpty
                        ? 'Address unavailable'
                        : restaurant.address,
                    maxLines: 1,
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
      ),
    );
  }
}

class _TitleRatingRow extends StatelessWidget {
  const _TitleRatingRow({required this.restaurant});

  final GoogleNearbyRestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            restaurant.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        const SizedBox(width: 6),
        if (restaurant.rating > 0) ...[
          Icon(Icons.star, size: 14, color: AppColors.primaryOrange),
          const SizedBox(width: 3),
          Text(
            restaurant.rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.primaryText1(context),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ] else
          Text(
            'No ratings yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.asset,
    required this.label,
    this.isStrong = false,
  });

  final String asset;
  final String label;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(asset, width: 12, height: 12, fit: BoxFit.contain),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 12,
              fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}
