import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/home_recommendation_item_model.dart';
import '../controller/home_shop_controller.dart';
import '../navigation/home_navigation.dart';

class RecommendedListScreen extends StatelessWidget {
  const RecommendedListScreen({super.key});

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
          title: Text(
            'Recommended for you',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Obx(() {
          final bool isLoading = shopController.isRecommendedLoading.value;
          final String error = shopController.recommendedError.value;
          final List<HomeRecommendationItemModel> items =
              shopController.recommendedItems;

          if (isLoading && items.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (items.isEmpty) {
            return Center(
              child: Text(
                error.isNotEmpty
                    ? 'Could not load recommendations'
                    : 'No recommendations available',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final HomeRecommendationItemModel item = items[index];
              return _RecommendedItem(item: item, onTap: () => _openItem(item));
            },
          );
        }),
      ),
    );
  }

  void _openItem(HomeRecommendationItemModel item) {
    if (item.type == 'shop' && item.restaurant != null) {
      HomeNavigation.openRestaurantDetailsById(item.restaurant!.id);
      return;
    }

    if (item.type == 'menu' && item.food != null) {
      HomeNavigation.openFoodDetailsById(item.food!.id);
    }
  }
}

class _RecommendedItem extends StatelessWidget {
  const _RecommendedItem({required this.item, this.onTap});

  final HomeRecommendationItemModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String imagePath = item.image.trim().isNotEmpty
        ? item.image
        : AppImages.homeRestaurant1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AdaptiveImage(
              path: imagePath,
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
                  style: TextStyle(
                    color: AppColors.primaryText(context),
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
                              style: TextStyle(
                                color: AppColors.primaryText(context),
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
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.primaryOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: TextStyle(
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
                        style: TextStyle(
                          color: AppColors.primaryText(context),
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
