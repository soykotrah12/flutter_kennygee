import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/controllers/wishlist_controller.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../data/model/food_model.dart';
import '../../data/model/restaurant_model.dart';
import '../controller/home_food_details_controller.dart';
import 'restaurant_reviews_screen.dart';

class SingleFoodScreen extends StatefulWidget {
  const SingleFoodScreen({this.food, this.menuId, super.key})
    : assert(
        food != null || (menuId != null && menuId != ''),
        'Either food or menuId must be provided',
      );

  final FoodModel? food;
  final String? menuId;

  @override
  State<SingleFoodScreen> createState() => _SingleFoodScreenState();
}

class _SingleFoodScreenState extends State<SingleFoodScreen>
    with WidgetsBindingObserver {
  late final HomeFoodDetailsController _detailsController;
  late final PageController _bannerController;
  late final FoodModel _fallbackFood;
  late final String _activeMenuId;
  late List<String> _bannerImages;
  late final Worker _detailsWorker;
  StreamSubscription<ApiMutationEvent>? _mutationSubscription;
  int _activeBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeMenuId = (widget.menuId ?? widget.food?.id ?? '').trim();
    _fallbackFood =
        widget.food ??
        FoodModel(
          id: _activeMenuId,
          name: '',
          image: '',
          price: 0,
          rating: 0,
          reviewsCount: 0,
          description: '',
          restaurantName: '',
          distance: '',
          address: '',
          openingHours: 'Hours not available',
        );

    _detailsController = HomeFoodDetailsController.ensureInitialized(
      _activeMenuId,
    );
    _bannerController = PageController();
    _bannerImages = _resolveBannerImages(_fallbackFood);
    _detailsWorker = ever<FoodModel?>(_detailsController.menu, (food) {
      if (food == null || !mounted) return;

      final List<String> nextImages = _resolveBannerImages(food);
      setState(() {
        _bannerImages = nextImages;
        _activeBannerIndex = 0;
      });

      if (_bannerController.hasClients) {
        _bannerController.jumpToPage(0);
      }
    });
    _mutationSubscription = ApiClient.mutationStream.listen((_) {
      if (!mounted) return;
      _detailsController.fetchMenuDetails(menuId: _activeMenuId);
    });
    _detailsController.fetchMenuDetails(menuId: _activeMenuId);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _detailsController.fetchMenuDetails(menuId: _activeMenuId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mutationSubscription?.cancel();
    _detailsWorker.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  FoodModel get _currentFood => _detailsController.menu.value ?? _fallbackFood;

  List<String> _resolveBannerImages(FoodModel food) {
    final List<String> images = food.images
        .where((image) => image.trim().isNotEmpty)
        .toList();

    if (images.isNotEmpty) {
      return images;
    }

    if (food.image.trim().isNotEmpty) {
      return <String>[food.image, food.image, food.image, food.image];
    }

    return <String>[''];
  }

  RestaurantModel get _restaurantFromFood {
    final FoodModel food = _currentFood;

    return RestaurantModel(
      id: food.shopId.trim().isNotEmpty ? food.shopId : 'food_rest_${food.id}',
      name: food.restaurantName,
      subtitle: '',
      image: food.image,
      rating: food.rating,
      reviewsCount: food.reviewsCount,
      distance: food.distance,
      address: food.address,
      openingHours: food.openingHours,
      isLiked: food.isLiked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final FoodModel food = _currentFood;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 395,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _bannerController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _bannerImages.length,
                          onPageChanged: (int index) {
                            setState(() => _activeBannerIndex = index);
                          },
                          itemBuilder: (_, index) {
                            return AdaptiveImage(
                              path: _bannerImages[index],
                              width: double.infinity,
                              height: 395,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 56,
                        left: 20,
                        child: _CircleActionButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Positioned(
                        top: 56,
                        right: 20,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4F6077,
                            ).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: WishlistIcon(
                              type: 'menu',
                              itemId: food.id,
                              initiallyWishlisted: food.isLiked,
                              color: AppColors.primaryOrange,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            _bannerImages.length,
                            (int index) => Padding(
                              padding: EdgeInsets.only(
                                right: index == _bannerImages.length - 1
                                    ? 0
                                    : 8,
                              ),
                              child: _Dot(active: _activeBannerIndex == index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.background(context),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    food.name,
                                    style: TextStyle(
                                      color: AppColors.primaryText(context),
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      height: 1.05,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$${food.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                            // const SizedBox(height: 0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColors.primaryOrange,
                                  size: 18,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  food.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: AppColors.primaryGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () async {
                                    await Get.to(
                                      () => RestaurantReviewsScreen(
                                        restaurant: _restaurantFromFood,
                                        shopId: food.shopId,
                                        menuId: food.id,
                                      ),
                                    );
                                    if (!mounted) return;
                                    _detailsController.fetchMenuDetails(
                                      menuId: _activeMenuId,
                                    );
                                  },
                                  child: Text(
                                    '(${food.reviewsCount} Reviews)',
                                    style: TextStyle(
                                      color: AppColors.primaryText(context),
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Description',
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              food.description,
                              style: TextStyle(
                                color: Color(0xFF6E6E6E),
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 35),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softCardColor(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: AdaptiveImage(
                                          path: food.image,
                                          width: 84,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              food.restaurantName,
                                              style: TextStyle(
                                                color: AppColors.primaryText(
                                                  context,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              food.distance,
                                              style: TextStyle(
                                                color: AppColors.primaryGreen,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.background(context),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            AppImages.map,
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Color(0xFF777777),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          food.address,
                                          style: TextStyle(
                                            color: Color(0xFF6E6E6E),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Color(0xFF777777),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Open - ${food.openingHours}',
                                          style: TextStyle(
                                            color: Color(0xFF6E6E6E),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: _BottomActionButton(
                    icon: Icons.turn_right,
                    label: 'Directions',
                    onTap: _openDirections,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _BottomActionButton(
                    icon: Icons.bookmark_border,
                    label: 'Save',
                    onTap: _saveFood,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDirections() async {
    await Get.to(() => const MapScreen());
  }

  Future<void> _saveFood() async {
    final bool canContinue = await requireLoginForFeature();
    if (!canContinue) return;

    final String menuId = _currentFood.id.trim();
    if (menuId.isEmpty) {
      _showSaveMessage('Unable to save this item right now.');
      return;
    }

    try {
      await Get.find<WishlistController>().toggleWishlist(
        type: 'menu',
        itemId: menuId,
      );
      if (!mounted) return;
      Get.snackbar(
        'Save',
        'Saved successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
    } catch (_) {
      if (!mounted) return;
      _showSaveMessage('Unable to save this item right now.');
    }
  }

  void _showSaveMessage(String message) {
    Get.snackbar(
      'Save',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardColor(context),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF4F6077).withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 10 : 10,
      height: active ? 10 : 10,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFF7B7E84),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 51,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(34),
          ),
          elevation: 0,
        ),
        icon: Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
