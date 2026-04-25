import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/repo/home_mock_data.dart';
import '../controller/home_shop_controller.dart';
import '../navigation/home_navigation.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  static const List<RestaurantModel> _items = HomeMockData.restaurantList;

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
        isScrollable: false,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        customAppBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 72,
          titleSpacing: 0,
          automaticallyImplyLeading: true,
          title: Text.rich(
            TextSpan(
              text: 'Restaurant List ',
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              children: const [
                TextSpan(
                  text: '(within 10km)',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                final List<RestaurantModel> source =
                    shopController.shops.isNotEmpty
                    ? shopController.shops
                    : _items;

                return GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: source.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (_, index) {
                    final RestaurantModel restaurant = source[index];
                    return _RestaurantGridCard(
                      item: restaurant,
                      onTap: () =>
                          HomeNavigation.openRestaurantDetails(restaurant),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantGridCard extends StatelessWidget {
  const _RestaurantGridCard({required this.item, this.onTap});

  final RestaurantModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  AdaptiveImage(
                    path: item.image,
                    width: double.infinity,
                    height: 184,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: WishlistIcon(
                          type: 'shop',
                          itemId: item.id,
                          initiallyWishlisted: item.isLiked,
                          color: AppColors.primaryOrange,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.visible,
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
                    size: 16,
                    color: AppColors.primaryOrange,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.distance,
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF31B24C),
                    size: 24,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.openingHours,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
