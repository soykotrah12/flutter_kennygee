import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/food_model.dart';
import '../controller/home_food_controller.dart';
import '../navigation/home_navigation.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with WidgetsBindingObserver {
  late final HomeFoodController _foodController;
  StreamSubscription<ApiMutationEvent>? _mutationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foodController = HomeFoodController.ensureInitialized();
    _mutationSubscription = ApiClient.mutationStream.listen((_) {
      if (!mounted) return;
      _foodController.fetchNearbyFoods();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _foodController.fetchNearbyFoods();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mutationSubscription?.cancel();
    super.dispose();
  }

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
              text: 'Food List ',
              style: TextStyle(
                color: AppColors.primaryText(context),
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
                final List<FoodModel> items = _foodController.foods;

                if (_foodController.isLoading.value && items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _foodController.fetchNearbyFoods,
                    child: _RefreshableState(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                }

                if (_foodController.error.value.isNotEmpty && items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _foodController.fetchNearbyFoods,
                    child: _RefreshableState(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _foodController.error.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _foodController.fetchNearbyFoods,
                              child: Text(
                                'Try again',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _foodController.fetchNearbyFoods,
                    child: _RefreshableState(
                      child: Text(
                        'No food available',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryGreen,
                  onRefresh: _foodController.fetchNearbyFoods,
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: items.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                    itemBuilder: (_, index) {
                      final FoodModel food = items[index];
                      return _FoodGridCard(
                        item: food,
                        onTap: () => HomeNavigation.openFoodDetails(food),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefreshableState extends StatelessWidget {
  const _RefreshableState({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.62,
          child: Center(child: child),
        ),
      ],
    );
  }
}

class _FoodGridCard extends StatelessWidget {
  const _FoodGridCard({required this.item, this.onTap});

  final FoodModel item;
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
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: WishlistIcon(
                          type: 'menu',
                          itemId: item.id,
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
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  Icon(Icons.star, size: 16, color: AppColors.primaryOrange),
                  const SizedBox(width: 2),
                  Text(
                    item.rating.toStringAsFixed(1),
                    style: TextStyle(
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
                  Icon(
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
                      style: TextStyle(
                        color: AppColors.primaryText(context),
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
                  Icon(
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
                      style: TextStyle(
                        color: AppColors.primaryText(context),
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
