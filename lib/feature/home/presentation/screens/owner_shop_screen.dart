import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/owner_shop_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_shop_card.dart';
import '../widgets/host_experience_card.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/shop_details_card.dart';
import 'owner_add_menu_screen.dart';
import 'owner_add_shop_screen.dart';
import 'owner_food_list_screen.dart';

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
  }

  Future<void> _openFoodList() async {
    final String shopId =
        _controller.ownerShop.value?.shopId ?? '69eee7f2f4449762ca5abced';
    await Get.to(() => OwnerFoodListScreen(shopId: shopId));
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    '12 items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Get.to(() => OwnerAddMenuScreen());
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
            MenuItemCard(
              isSpecialOffer: true,
              onEditTap: () {
                // Placeholder - these are demo cards without real menu data
                Get.snackbar(
                  'Info',
                  'Click "See All" to view and edit menu items',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemCard(
              isSpecialOffer: false,
              onEditTap: () {
                // Placeholder - these are demo cards without real menu data
                Get.snackbar(
                  'Info',
                  'Click "See All" to view and edit menu items',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
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
