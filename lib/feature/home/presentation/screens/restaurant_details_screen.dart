import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/controllers/wishlist_controller.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/login_required_dialog.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/restaurant_model.dart';
import '../controller/home_shop_details_controller.dart';
import 'restaurant_reviews_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({this.restaurant, this.shopId, super.key})
    : assert(
        restaurant != null || (shopId != null && shopId != ''),
        'Either restaurant or shopId must be provided',
      );

  final RestaurantModel? restaurant;
  final String? shopId;

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen>
    with WidgetsBindingObserver {
  static const String _bookmarkType = 'bookmark_shop';
  static int _buildCount = 0;

  late final HomeShopDetailsController _detailsController;
  late final String _activeShopId;
  late final ApiClient _apiClient;
  late final WishlistController _wishlistController;
  Worker? _restaurantSeedWorker;
  bool _isBookmarkLoading = false;

  int selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeShopId = (widget.shopId ?? widget.restaurant?.id ?? '').trim();

    _detailsController = HomeShopDetailsController.ensureInitialized(
      _activeShopId,
    );
    _apiClient = ApiClient();
    _wishlistController = Get.find<WishlistController>();
    _wishlistController.seedWishlist(
      type: 'shop',
      itemId: _activeShopId,
      isWishlisted: widget.restaurant?.isLiked ?? false,
    );
    _restaurantSeedWorker = ever<RestaurantModel?>(
      _detailsController.restaurant,
      (RestaurantModel? value) {
        if (value == null) return;
        _wishlistController.seedWishlist(
          type: 'shop',
          itemId: value.id,
          isWishlisted: value.isLiked,
        );
      },
    );
    _detailsController.fetchShopDetails(shopId: _activeShopId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restaurantSeedWorker?.dispose();
    final String tag = HomeShopDetailsController.tagForShop(_activeShopId);
    if (Get.isRegistered<HomeShopDetailsController>(tag: tag)) {
      Get.delete<HomeShopDetailsController>(tag: tag);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _detailsController.fetchShopDetails(shopId: _activeShopId, force: true);
    }
  }

  RestaurantModel? get _currentRestaurant =>
      _detailsController.restaurant.value ?? widget.restaurant;

  Future<void> _toggleShopBookmark() async {
    if (_isBookmarkLoading) return;
    final bool canContinue = await requireLoginForFeature(
      featureName: 'bookmarks',
    );
    if (!canContinue) return;

    final String shopId = _activeShopId.trim();
    if (shopId.isEmpty) return;

    final bool previous = _wishlistController.isWishlisted(
      _bookmarkType,
      shopId,
    );
    setState(() {
      _isBookmarkLoading = true;
    });
    _wishlistController.setWishlisted(
      type: _bookmarkType,
      itemId: shopId,
      isWishlisted: !previous,
      bumpVersion: false,
    );

    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiConstants.bookmark.toggleBookmark,
      data: <String, dynamic>{'shopId': shopId},
      fromJsonT: _asMap,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        _wishlistController.setWishlisted(
          type: _bookmarkType,
          itemId: shopId,
          isWishlisted: previous,
          bumpVersion: false,
        );
        setState(() {
          _isBookmarkLoading = false;
        });
        Get.snackbar(
          'Bookmark Failed',
          _cleanErrorMessage(failure.message),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.cardColor(context),
        );
      },
      (success) {
        final String message = success.message.toLowerCase();
        bool resolvedState = !previous;
        if (message.contains('remove') || message.contains('unbookmark')) {
          resolvedState = false;
        } else if (message.contains('bookmark') || message.contains('add')) {
          resolvedState = true;
        }
        _wishlistController.setWishlisted(
          type: _bookmarkType,
          itemId: shopId,
          isWishlisted: resolvedState,
          bumpVersion: false,
        );
        setState(() {
          _isBookmarkLoading = false;
        });
        Get.snackbar(
          'Bookmark',
          resolvedState ? 'Saved successfully.' : 'Removed from bookmarks.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    debugPrint('[RestaurantDetailsScreen] build count=$_buildCount');

    final List<String> dishIcons = [
      'assets/icons/pasta.png',
      'assets/icons/burger.png',
      'assets/icons/cheese.png',
    ];

    return Obx(() {
      final RestaurantModel? restaurant = _currentRestaurant;
      final bool isShopBookmarked = _wishlistController.isWishlisted(
        _bookmarkType,
        _activeShopId,
      );
      if (restaurant == null) {
        final bool isLoading = _detailsController.isLoading.value;
        final String error = _detailsController.error.value;

        return Container(
          color: AppColors.background(context),
          child: AppScaffold(
            useSafeArea: true,
            isScrollable: false,
            backgroundColor: Colors.transparent,
            bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            customAppBar: _detailsAppBar(context),
            body: Center(
              child: isLoading
                  ? CircularProgressIndicator(color: AppColors.primaryGreen)
                  : Text(
                      error.isNotEmpty
                          ? 'Could not load restaurant'
                          : 'No restaurants available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
            ),
          ),
        );
      }

      final List<RestaurantMenuCategoryModel> menuCategories = restaurant
          .menuCategories
          .where((category) => category.items.isNotEmpty)
          .toList();
      final List<String> popularDishes = menuCategories.isNotEmpty
          ? menuCategories.map((category) => category.name).toList()
          : restaurant.popularDishes.isNotEmpty
          ? restaurant.popularDishes
          : restaurant.menuItems.map((item) => item.name).toList();
      final int safeSelectedIndex = popularDishes.isEmpty
          ? 0
          : selectedCategoryIndex.clamp(0, popularDishes.length - 1);
      final List<RestaurantMenuItemModel> visibleMenuItems =
          menuCategories.isNotEmpty
          ? menuCategories[safeSelectedIndex].items
          : restaurant.menuItems;

      return Container(
        color: AppColors.background(context),
        child: AppScaffold(
          useSafeArea: true,
          isScrollable: false,
          backgroundColor: Colors.transparent,
          bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          customAppBar: _detailsAppBar(context),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCard(restaurant: restaurant),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _RatingPill(
                      rating: restaurant.rating,
                      reviewsCount: restaurant.reviewsCount,
                      onReviewsTap: () async {
                        await Get.to(
                          () => RestaurantReviewsScreen(
                            restaurant: restaurant,
                            shopId: restaurant.id,
                          ),
                        );
                        if (!mounted) return;
                        _detailsController.fetchShopDetails(
                          shopId: _activeShopId,
                          force: true,
                        );
                      },
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _isBookmarkLoading ? null : _toggleShopBookmark,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryGreen,
                            width: 2,
                          ),
                        ),
                        child: _isBookmarkLoading
                            ? Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : Icon(
                                isShopBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                _InfoRow(
                  icon: Icons.location_on,
                  iconColor: AppColors.primaryOrange,
                  title: 'Location',
                  value: restaurant.address.isNotEmpty
                      ? restaurant.address
                      : restaurant.distance,
                ),
                const SizedBox(height: 18),
                _OpeningHoursSection(
                  openTime: restaurant.openTime,
                  closeTime: restaurant.closeTime,
                  isClosedToday: restaurant.isClosedToday,
                  operatingHours: restaurant.operatingHours,
                ),
                const SizedBox(height: 26),
                Text(
                  'Popular Dishes',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 12),
                if (popularDishes.isNotEmpty)
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularDishes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, index) {
                        final String dish = popularDishes[index];

                        final String iconImage =
                            dishIcons[index % dishIcons.length];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategoryIndex = index;
                            });
                          },
                          child: _DishChip(
                            label: dish,
                            iconImage: iconImage,
                            isActive: safeSelectedIndex == index,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Text(
                    'No popular dishes available',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                const SizedBox(height: 16),
                if (visibleMenuItems.isNotEmpty)
                  ...visibleMenuItems.map((item) => _MenuItemTile(item: item))
                else
                  Text(
                    'No menu items available',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

AppBar _detailsAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    toolbarHeight: 72,
    titleSpacing: 0,
    automaticallyImplyLeading: true,
    title: Text.rich(
      TextSpan(
        text: 'Details ',
        style: TextStyle(
          color: AppColors.primaryText(context),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
        ),
        children: [
          TextSpan(
            text: '(within 10km Restaurant)',
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    ),
  );
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.restaurant});

  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          AdaptiveImage(
            path: restaurant.image,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 2),
                      if (restaurant.subtitle.isNotEmpty)
                        Text(
                          restaurant.subtitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: WishlistIcon(
                      type: 'shop',
                      itemId: restaurant.id,
                      initiallyWishlisted: restaurant.isLiked,
                      color: AppColors.primaryOrange,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({
    required this.rating,
    required this.reviewsCount,
    this.onReviewsTap,
  });

  final double rating;
  final int reviewsCount;
  final VoidCallback? onReviewsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rating > 0) ...[
            Icon(Icons.star, color: AppColors.primaryOrange, size: 16),
            const SizedBox(width: 8),
            Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(width: 8),
          ],
          InkWell(
            onTap: onReviewsTap,
            child: Text(
              rating > 0 ? '($reviewsCount Reviews)' : 'No ratings yet',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 16,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OpeningHoursSection extends StatelessWidget {
  const _OpeningHoursSection({
    required this.openTime,
    required this.closeTime,
    required this.isClosedToday,
    required this.operatingHours,
  });

  final String openTime;
  final String closeTime;
  final bool isClosedToday;
  final List<RestaurantOperatingHoursEntryModel> operatingHours;

  @override
  Widget build(BuildContext context) {
    final bool hasAnyHours =
        operatingHours.isNotEmpty ||
        openTime.trim().isNotEmpty ||
        closeTime.trim().isNotEmpty ||
        isClosedToday;
    final List<RestaurantOperatingHoursEntryModel> entries =
        operatingHours.isNotEmpty
        ? operatingHours
        : hasAnyHours
        ? <RestaurantOperatingHoursEntryModel>[
            RestaurantOperatingHoursEntryModel(
              day: 'Today',
              open: openTime,
              close: closeTime,
              isClosed: isClosedToday,
            ),
          ]
        : const <RestaurantOperatingHoursEntryModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              color: AppColors.primaryGreen,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Operating Hours',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 28,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    'Hours not available',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )
              : Column(
                  children: List<Widget>.generate(entries.length, (int index) {
                    final RestaurantOperatingHoursEntryModel entry =
                        entries[index];
                    return Column(
                      children: [
                        _OpeningHoursDayRow(entry: entry),
                        if (index != entries.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppColors.softCardColor(context),
                            indent: 14,
                            endIndent: 14,
                          ),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}

class _OpeningHoursDayRow extends StatelessWidget {
  const _OpeningHoursDayRow({required this.entry});

  final RestaurantOperatingHoursEntryModel entry;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double dayColumnWidth = (constraints.maxWidth * 0.30)
            .clamp(74.0, 120.0)
            .toDouble();
        final bool hasOpen = entry.open.trim().isNotEmpty;
        final bool hasClose = entry.close.trim().isNotEmpty;
        final String singleLabel = hasOpen
            ? _formatTime(entry.open)
            : hasClose
            ? _formatTime(entry.close)
            : 'Hours not available';
        final String openLabel = _formatTime(entry.open);
        final String closeLabel = _formatTime(entry.close);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: dayColumnWidth,
                child: Text(
                  entry.day,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: entry.isClosed
                      ? const _OpeningHoursChip(
                          label: 'Closed',
                          textColor: Color(0xFFF04E45),
                        )
                      : Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: hasOpen && hasClose
                              ? <Widget>[
                                  _OpeningHoursChip(label: openLabel),
                                  Text(
                                    '\u2212',
                                    style: TextStyle(
                                      color: AppColors.primaryGreen,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  _OpeningHoursChip(label: closeLabel),
                                ]
                              : <Widget>[_OpeningHoursChip(label: singleLabel)],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OpeningHoursChip extends StatelessWidget {
  const _OpeningHoursChip({required this.label, this.textColor});

  final String label;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? AppColors.primaryText(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

String _formatTime(String value) {
  final String trimmed = value.trim();
  final RegExpMatch? match = RegExp(
    r'(\d{1,2})(?::(\d{2}))?\s*([aApP][mM])',
  ).firstMatch(trimmed);

  if (match == null) {
    return trimmed;
  }

  final String hour = (int.tryParse(match.group(1) ?? '') ?? 0)
      .toString()
      .padLeft(2, '0');
  final String minute = (match.group(2) ?? '00').padLeft(2, '0');
  final String period = (match.group(3) ?? '').toUpperCase();

  return '$hour:$minute $period';
}

class _DishChip extends StatelessWidget {
  const _DishChip({
    required this.label,
    required this.iconImage,
    required this.isActive,
  });

  final String label;
  final String iconImage;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 13, backgroundImage: AssetImage(iconImage)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});

  final RestaurantMenuItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider(context), width: 1.2),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AdaptiveImage(
              path: item.image,
              width: 78,
              height: 78,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Price ',
                    style: TextStyle(
                      color: AppColors.primaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                    children: [
                      TextSpan(
                        text: '\$${item.price.toStringAsFixed(0)}',
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
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: WishlistIcon(
                type: 'menu',
                itemId: item.id,
                initiallyWishlisted: item.isLiked,
                color: AppColors.primaryOrange,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

String _cleanErrorMessage(String message) {
  final String trimmed = message.trim();
  if (trimmed.isEmpty || trimmed.startsWith('{') || trimmed.startsWith('[')) {
    return 'Unable to complete this action right now.';
  }
  return trimmed;
}
