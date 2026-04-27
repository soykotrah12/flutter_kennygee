import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/owner_food_list_controller.dart';
import '../widgets/menu_item_card.dart';
import '../../data/model/update_menu_response_model.dart';
import '../screens/owner_update_menu_screen.dart';

class OwnerFoodListScreen extends StatefulWidget {
  const OwnerFoodListScreen({super.key, required this.shopId});

  final String shopId;

  @override
  State<OwnerFoodListScreen> createState() => _OwnerFoodListScreenState();
}

class _OwnerFoodListScreenState extends State<OwnerFoodListScreen> {
  late final OwnerFoodListController _controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    _tag = OwnerFoodListController.tagForShop(widget.shopId);
    _controller = OwnerFoodListController.ensureInitialized(widget.shopId);
  }

  @override
  void dispose() {
    if (Get.isRegistered<OwnerFoodListController>(tag: _tag)) {
      Get.delete<OwnerFoodListController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      appBarTitle: 'Food List',
      centerTitle: false,
      bodyPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (_controller.foods.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _controller.error.value.isNotEmpty
                        ? _controller.error.value
                        : 'No food items found',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _controller.fetchShopFoods,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: _controller.foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _controller.foods[index];
            final bool hasFraction = item.price % 1 != 0;
            final String formattedPrice = hasFraction
                ? item.price.toStringAsFixed(2)
                : item.price.toStringAsFixed(0);

            return MenuItemCard(
              isSpecialOffer: item.specialOffer,
              imagePath: item.image.isNotEmpty ? item.image : AppImages.food,
              dishName: item.name.isNotEmpty ? item.name : 'Unnamed item',
              priceText: '\$$formattedPrice',
              subtitle: item.description.isNotEmpty
                  ? item.description
                  : 'Food item',
              offerLabel: item.specialOffer ? item.offerText : 'Regular',
              onEditTap: () {
                final menuData =
                    UpdateMenuResponseModel.fromFoodModel(item);
                Get.to(
                  () => OwnerUpdateMenuScreen(
                    menuId: item.id,
                    menuData: menuData,
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
