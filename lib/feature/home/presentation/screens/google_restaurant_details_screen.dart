import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../map/data/models/map_restaurant_model.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../data/model/google_nearby_restaurant_model.dart';

class GoogleRestaurantDetailsScreen extends StatelessWidget {
  const GoogleRestaurantDetailsScreen({required this.restaurant, super.key});

  final GoogleNearbyRestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark
          ? BoxDecoration(color: AppColors.darkBackground)
          : BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.rolebackground),
                fit: BoxFit.cover,
              ),
            ),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: true,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        customAppBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          title: Text(
            'Google Restaurant',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AdaptiveImage(
                path: restaurant.imageUrl,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              restaurant.title,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 24,
                height: 1.15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(
                  icon: Icons.star_rounded,
                  label: restaurant.rating > 0
                      ? '${restaurant.rating.toStringAsFixed(1)} ${restaurant.reviewsLabel}'
                      : 'No ratings yet',
                ),
                _InfoPill(
                  icon: Icons.location_on_rounded,
                  label: restaurant.distanceLabel,
                ),
                _InfoPill(
                  icon: Icons.access_time_rounded,
                  label: restaurant.openStatusLabel,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Address',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              restaurant.address.isEmpty
                  ? 'Address unavailable'
                  : restaurant.address,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _openDirections(context),
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDirections(BuildContext context) {
    if (!restaurant.hasValidCoordinates) {
      Get.snackbar(
        'Directions',
        'Restaurant location is unavailable.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.cardColor(context),
      );
      return;
    }

    Get.to(
      () => MapScreen(
        autoOpenDirections: true,
        initialRestaurant: MapRestaurantModel(
          shopId: 'google:${restaurant.googlePlaceId}',
          restaurantName: restaurant.title,
          imageUrl: restaurant.imageUrl,
          address: restaurant.address,
          rating: restaurant.rating,
          reviewsCount: restaurant.totalRatings,
          distanceLabel: restaurant.distanceLabel,
          latitude: restaurant.latitude,
          longitude: restaurant.longitude,
          isClosedToday: restaurant.isOpenNow == false,
          openTime: restaurant.openStatusLabel,
          closeTime: '',
          isExternalGooglePlace: true,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
