import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import 'food_list_screen.dart';
import 'restaurant_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.rolebackground),
          fit: BoxFit.cover,
        ),
      ),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: true,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  AppImages.appLogo,
                  width: 32,
                  height: 51,
                  fit: BoxFit.contain,
                ),
                const Spacer(),
                Image.asset(
                  AppImages.ai,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppImages.event,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Hungry? Discover What\'s nearby.',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.1,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryGreen, width: 1.2),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'Search Restaurant, dishes...',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 52,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(9),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppImages.search,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _FilterChip(label: 'All', active: true, icon: AppImages.all),
                SizedBox(width: 8),
                _FilterChip(
                  label: 'Restaurant List',
                  icon: AppImages.restaurantlist,
                  onTap: _openRestaurantList,
                ),
                SizedBox(width: 8),
                _FilterChip(
                  label: 'Food List',
                  icon: AppImages.foodlist,
                  onTap: _openFoodList,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionHeader(
              title: 'Nearby Restaurants',
              subtitle: '(within 10km)',
              onSeeAll: _openRestaurantList,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 224,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  _NearbyCard(image: AppImages.homeRestaurant1),
                  SizedBox(width: 12),
                  _NearbyCard(image: AppImages.homeRestaurant2),
                  SizedBox(width: 12),
                  _NearbyCard(image: AppImages.homeRestaurant2),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _OnlyTitleHeader(title: 'Recommended for you'),
            const SizedBox(height: 10),
            const _RecommendedItem(
              image: AppImages.homeRestaurant3,
              rating: '5.0',
            ),
            const SizedBox(height: 10),
            const _RecommendedItem(
              image: AppImages.homeRestaurant1,
              rating: '5.0',
            ),
            const SizedBox(height: 10),
            const _RecommendedItem(
              image: AppImages.homeRestaurant2,
              rating: '5.0',
            ),
            const SizedBox(height: 10),
            const _RecommendedItem(
              image: AppImages.homeRestaurant3,
              rating: '5.0',
            ),
            const SizedBox(height: 10),
            const _RecommendedItem(
              image: AppImages.homeRestaurant1,
              rating: '4.8',
            ),
          ],
        ),
      ),
    );
  }

  void _openRestaurantList() {
    Get.to(() => const RestaurantListScreen());
  }

  void _openFoodList() {
    Get.to(() => const FoodListScreen());
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    this.active = false,
    this.onTap,
  });

  final String label;
  final String icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : AppColors.appBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryGreen),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(icon, width: 20, height: 20, fit: BoxFit.contain),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppColors.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See all',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ],
    );
  }
}

class _OnlyTitleHeader extends StatelessWidget {
  const _OnlyTitleHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.1,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        const Text(
          'See all',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _NearbyCard extends StatelessWidget {
  const _NearbyCard({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
              spreadRadius: 0,
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
              child: Stack(
                children: [
                  Image.asset(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryWhite,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 20,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Side view club',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  Icon(Icons.star, size: 12, color: AppColors.primaryOrange),
                  SizedBox(width: 4),
                  Text(
                    '5.0',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  Image.asset(
                    AppImages.location,
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '1.2 miles away',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 2, 8, 8),
              child: Row(
                children: [
                  Image.asset(
                    AppImages.clock,
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '11:00 AM - 10:00 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
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

class _RecommendedItem extends StatelessWidget {
  const _RecommendedItem({required this.image, required this.rating});

  final String image;
  final String rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(image, width: 90, height: 90, fit: BoxFit.cover),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Side view club sandwich made...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Image.asset(
                          AppImages.location,
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            '1.2 miles away',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Image.asset(
                    AppImages.clock,
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '11:00 AM - 10:00 PM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
