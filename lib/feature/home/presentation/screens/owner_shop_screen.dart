import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/constants/app_images.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/owner_shop_controller.dart';
import '../controller/owner_food_list_controller.dart';
import '../../data/model/food_model.dart';
import '../../data/model/update_menu_response_model.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_shop_card.dart';
import '../widgets/host_experience_card.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/shop_details_card.dart';
import 'owner_add_menu_screen.dart';
import 'owner_add_shop_screen.dart';
import 'owner_food_list_screen.dart';
import 'owner_update_menu_screen.dart';

class OwnerShopScreen extends StatefulWidget {
  const OwnerShopScreen({super.key});

  @override
  State<OwnerShopScreen> createState() => _OwnerShopScreenState();
}

class _OwnerShopScreenState extends State<OwnerShopScreen> {
  late final OwnerShopController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ensureOwnerShopController();
  }

  Future<void> _openAddOrEditShop() async {
    await Get.to(() => const OwnerAddShopScreen());
    await _controller.refreshShop();
  }

  Future<void> _openFoodList() async {
    final String shopId = _controller.ownerShop.value?.shopId ?? '';
    if (shopId.isEmpty) return;
    await Get.to(() => OwnerFoodListScreen(shopId: shopId));
  }

  Future<void> _openMenuEditor(FoodModel item, String shopId) async {
    final String? result = await Get.to<String>(
      () => OwnerUpdateMenuScreen(
        menuId: item.id,
        menuData: UpdateMenuResponseModel.fromFoodModel(item, shopId: shopId),
      ),
    );

    if (result == null) return;

    await _controller.refreshShop();
    final OwnerFoodListController ownerFoodCtrl =
        OwnerFoodListController.ensureInitialized(shopId);
    await ownerFoodCtrl.fetchShopFoods();

    Get.snackbar(
      'Success',
      result == 'deleted'
          ? 'Menu item deleted successfully'
          : 'Menu item updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<bool> _toggleSpecialOffer(FoodModel item, String shopId) async {
    final ownerFoodCtrl = OwnerFoodListController.ensureInitialized(shopId);
    final bool success = await ownerFoodCtrl.toggleSpecialOffer(item.id);
    if (!success || !mounted) return false;

    await ownerFoodCtrl.fetchShopFoods();
    await _controller.refreshShop();

    Get.snackbar(
      'Success',
      item.specialOffer ? 'Special offer disabled' : 'Special offer enabled',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      body: Obx(() {
        final shop = _controller.ownerShop.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shop == null
                ? EmptyShopCard(onTap: _openAddOrEditShop)
                : ShopDetailsCard(
                    title: shop.restaurantName,
                    subtitle: shop.location.address,
                    onEditTap: _openAddOrEditShop,
                  ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Text(
                  'Menu Management',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Builder(
                  builder: (context) {
                    final bool hasShop =
                        shop != null && shop.shopId.trim().isNotEmpty;
                    if (!hasShop) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          '0 items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    final ownerFoodCtrl =
                        OwnerFoodListController.ensureInitialized(shop.shopId);
                    return Obx(() {
                      final int count = ownerFoodCtrl.foods.length;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          '$count items',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  final shop = _controller.ownerShop.value;
                  final bool? created = await Get.to<bool>(
                    () => OwnerAddMenuScreen(shopId: shop?.shopId),
                  );

                  if (created == true && shop != null) {
                    final ownerFoodCtrl =
                        OwnerFoodListController.ensureInitialized(shop.shopId);
                    await ownerFoodCtrl.fetchShopFoods();
                    Get.snackbar(
                      'Success',
                      'Menu item added successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.primaryGreen,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(12),
                    );
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text(
                  'Add new Item',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Builder(
              builder: (context) {
                final bool hasShop =
                    shop != null && shop.shopId.trim().isNotEmpty;
                if (!hasShop) {
                  return Column(
                    children: const [
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          'No menu item',
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                }

                final ownerFoodCtrl = OwnerFoodListController.ensureInitialized(
                  shop.shopId,
                );

                return Obx(() {
                  if (ownerFoodCtrl.isLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    );
                  }

                  if (ownerFoodCtrl.foods.isEmpty) {
                    return Column(
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            ownerFoodCtrl.error.value.isNotEmpty
                                ? ownerFoodCtrl.error.value
                                : 'No menu item',
                            style: const TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: ownerFoodCtrl.fetchShopFoods,
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    );
                  }

                  // Show up to 2 items
                  final int showCount = ownerFoodCtrl.foods.length >= 2
                      ? 2
                      : ownerFoodCtrl.foods.length;
                  final List foods = ownerFoodCtrl.foods
                      .take(showCount)
                      .toList();

                  return Column(
                    children: [
                      for (int i = 0; i < foods.length; i++) ...[
                        const SizedBox(height: 10),
                        Builder(
                          builder: (ctx) {
                            final item = foods[i];
                            final bool hasFraction = item.price % 1 != 0;
                            final String formattedPrice = hasFraction
                                ? item.price.toStringAsFixed(2)
                                : item.price.toStringAsFixed(0);

                            return MenuItemCard(
                              isSpecialOffer: item.specialOffer,
                              imagePath: item.image.isNotEmpty
                                  ? item.image
                                  : AppImages.food,
                              dishName: item.name.isNotEmpty
                                  ? item.name
                                  : 'Unnamed item',
                              priceText: '\$${formattedPrice}',
                              subtitle: item.description.isNotEmpty
                                  ? item.description
                                  : 'Food item',
                              offerLabel: item.specialOffer
                                  ? item.offerText
                                  : 'Regular',
                              onOfferToggle: (value) =>
                                  _toggleSpecialOffer(item, shop.shopId),
                              onEditTap: () {
                                _openMenuEditor(item, shop.shopId);
                              },
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: _openFoodList,
                          child: const Text(
                            'See All',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Event Hosting',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const OwnerEventCard(),
            const SizedBox(height: 18),
            const HostExperienceCard(),
          ],
        );
      }),
    );
  }
}
