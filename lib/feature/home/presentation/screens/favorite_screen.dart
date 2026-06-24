import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../../data/model/wishlist_item_model.dart';
import '../controller/home_wishlist_controller.dart';
import '../navigation/home_navigation.dart';
import '../../../../core/common/controllers/wishlist_controller.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final AuthFlowController _flowController;
  HomeWishlistController? _wishlistController;
  WishlistController? _globalWishlistController;
  Worker? _wishlistChangeWorker;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
    _searchController = TextEditingController();
    if (!_flowController.isGuestMode.value) {
      _ensureWishlistControllers();
    }
  }

  @override
  void dispose() {
    _wishlistChangeWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<WishlistItemModel> _applySearch(List<WishlistItemModel> items) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final String name = item.name.toLowerCase();
      final String description = item.description.toLowerCase();
      final String distance = item.distance.toLowerCase();
      final String time = item.openingHours.toLowerCase();
      return name.contains(query) ||
          description.contains(query) ||
          distance.contains(query) ||
          time.contains(query);
    }).toList();
  }

  void _ensureWishlistControllers() {
    if (_wishlistController != null && _globalWishlistController != null) {
      return;
    }

    _wishlistController = HomeWishlistController.ensureInitialized();
    _globalWishlistController = Get.find<WishlistController>();
    _wishlistChangeWorker = ever<int>(
      _globalWishlistController!.changeVersion,
      (_) {
        if (!mounted) {
          return;
        }
        _wishlistController?.refreshCurrentTab();
      },
    );
    if (_wishlistController!.items.isEmpty &&
        !_wishlistController!.isLoading.value) {
      _wishlistController!.refreshCurrentTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardAspectRatio = screenWidth < 370 ? 0.66 : 0.72;
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
        isScrollable: false,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
        body: Obx(() {
          if (_flowController.isGuestMode.value) {
            return const GuestLoginRequiredView(
              message: 'Please log in to use Favorite features.',
            );
          }

          _ensureWishlistControllers();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                  color: Colors.transparent,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              border: InputBorder.none,
                            ),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                            decoration: InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText: 'Search Restaurant, dishes...',
                              hintStyle: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                        FocusScope.of(context).unfocus();
                      },
                      child: Container(
                        width: 56,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(14),
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            AppImages.search,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final HomeWishlistController wishlistController =
                    _wishlistController!;
                final WishlistTab activeTab =
                    wishlistController.activeTab.value;

                return Row(
                  children: [
                    _FavoriteFilterChip(
                      label: 'All',
                      activeIcon: AppImages.all,
                      inactiveIcon: AppImages.allcolored,
                      isActive: activeTab == WishlistTab.all,
                      onTap: () =>
                          wishlistController.changeTab(WishlistTab.all),
                    ),
                    const SizedBox(width: 10),
                    _FavoriteFilterChip(
                      label: 'Restaurant List',
                      activeIcon: AppImages.restaurantlistclored,
                      inactiveIcon: AppImages.restaurantlist,
                      isActive: activeTab == WishlistTab.restaurant,
                      onTap: () =>
                          wishlistController.changeTab(WishlistTab.restaurant),
                    ),
                    const SizedBox(width: 10),
                    _FavoriteFilterChip(
                      label: 'Food List',
                      activeIcon: AppImages.foodlist,
                      inactiveIcon: AppImages.foodlist,
                      isActive: activeTab == WishlistTab.food,
                      onTap: () =>
                          wishlistController.changeTab(WishlistTab.food),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 14),
              Obx(() {
                final HomeWishlistController wishlistController =
                    _wishlistController!;
                final WishlistController globalWishlistController =
                    _globalWishlistController!;
                final bool isSyncing =
                    wishlistController.isLoading.value ||
                    globalWishlistController.loadingItems.isNotEmpty;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSyncing
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            color: AppColors.primaryGreen,
                            backgroundColor: AppColors.softCardColor(context),
                          ),
                        )
                      : const SizedBox(height: 10),
                );
              }),
              Expanded(
                child: Obx(() {
                  final HomeWishlistController wishlistController =
                      _wishlistController!;
                  final List<WishlistItemModel> items =
                      wishlistController.items;
                  final List<WishlistItemModel> filteredItems = _applySearch(
                    items,
                  );

                  if (wishlistController.isLoading.value && items.isEmpty) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  if (wishlistController.error.value.isNotEmpty &&
                      items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              wishlistController.error.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: wishlistController.refreshCurrentTab,
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
                    );
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No wishlist items found',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  }

                  if (filteredItems.isEmpty) {
                    return Center(
                      child: Text(
                        'No matching items found',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: cardAspectRatio,
                    ),
                    itemBuilder: (_, index) {
                      return _FavoriteGridCard(item: filteredItems[index]);
                    },
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FavoriteFilterChip extends StatelessWidget {
  const _FavoriteFilterChip({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
    this.onTap,
  });

  final String label;
  final String activeIcon;
  final String inactiveIcon;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isActive ? activeIcon : inactiveIcon,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
}

class _FavoriteGridCard extends StatelessWidget {
  const _FavoriteGridCard({required this.item});

  final WishlistItemModel item;

  void _openDetails() {
    final String id = item.id.trim();
    if (id.isEmpty) return;

    if (item.type == WishlistItemType.restaurant) {
      HomeNavigation.openRestaurantDetailsById(id);
      return;
    }

    HomeNavigation.openFoodDetailsById(id);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDetails,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
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
                    height: 145,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.cardColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: WishlistIcon(
                          type: item.type.apiType,
                          itemId: item.id,
                          initiallyWishlisted: item.isLiked,
                          color: AppColors.primaryOrange,
                          size: 20,
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
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  if (item.rating > 0) ...[
                    Icon(Icons.star, size: 12, color: AppColors.primaryOrange),
                    const SizedBox(width: 2),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ] else
                    Text(
                      'No ratings yet',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
