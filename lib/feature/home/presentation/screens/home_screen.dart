import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/home_recommendation_item_model.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_mock_data.dart';
import '../controller/home_shop_controller.dart';
import '../navigation/home_navigation.dart';
import 'food_list_screen.dart';
import 'restaurant_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<RestaurantModel> _nearbyRestaurants =
      HomeMockData.nearbyRestaurants;
  static const List<HomeRecommendationItemModel> _recommendedItems =
      HomeMockData.recommendedItems;

  @override
  Widget build(BuildContext context) {
    final HomeShopController shopController =
        HomeShopController.ensureInitialized();

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
                InkWell(
                  onTap: HomeNavigation.openEvents,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
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
            Obx(() {
              final List<RestaurantModel> source =
                  shopController.shops.isNotEmpty
                  ? shopController.shops.take(3).toList()
                  : _nearbyRestaurants;

              return SizedBox(
                height: 224,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: source.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, index) {
                    final RestaurantModel restaurant = source[index];
                    return _NearbyCard(
                      restaurant: restaurant,
                      onTap: () =>
                          HomeNavigation.openRestaurantDetails(restaurant),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 18),
            const _OnlyTitleHeader(title: 'Recommended for you'),
            const SizedBox(height: 10),
            ...List<Widget>.generate(_recommendedItems.length, (index) {
              final HomeRecommendationItemModel item = _recommendedItems[index];
              final VoidCallback? onTap = item.type == 'restaurant'
                  ? () => HomeNavigation.openRestaurantDetails(item.restaurant!)
                  : item.type == 'food' && item.food != null
                  ? () => HomeNavigation.openFoodDetails(item.food!)
                  : null;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _recommendedItems.length - 1 ? 0 : 10,
                ),
                child: _RecommendedItem(item: item, onTap: onTap),
              );
            }),
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
  const _NearbyCard({required this.restaurant, this.onTap});

  final RestaurantModel restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                    AdaptiveImage(
                      path: restaurant.image,
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
                        child: Center(
                          child: WishlistIcon(
                            type: 'shop',
                            itemId: restaurant.id,
                            initiallyWishlisted: restaurant.isLiked,
                            size: 20,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
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
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.location,
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.distance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: Row(
                  children: [
                    Image.asset(
                      AppImages.clock,
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        restaurant.openingHours,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
      ),
    );
  }
}

class _RecommendedItem extends StatelessWidget {
  const _RecommendedItem({required this.item, this.onTap});

  final HomeRecommendationItemModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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
                          Expanded(
                            child: Text(
                              item.distance,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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
                      item.rating.toStringAsFixed(1),
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
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.openingHours,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
      ),
    );
  }
}
