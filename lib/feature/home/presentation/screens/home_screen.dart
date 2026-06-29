import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/home_recommendation_item_model.dart';
import '../../data/model/restaurant_model.dart';
import '../controller/home_shop_controller.dart';
import 'events_screen.dart';
import 'food_list_screen.dart';
import 'recommended_list_screen.dart';
import 'restaurant_details_screen.dart';
import 'restaurant_list_screen.dart';
import 'single_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final TextEditingController _searchController;
  late final HomeShopController _shopController;
  StreamSubscription<ApiMutationEvent>? _mutationSubscription;
  String _searchQuery = '';
  bool _isRefreshingHomeData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController = TextEditingController();
    _shopController = HomeShopController.ensureInitialized();
    _mutationSubscription = ApiClient.mutationStream.listen((_) {
      if (!mounted) return;
      _refreshHomeData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshHomeData();
    }
  }

  Future<void> _refreshHomeData() async {
    if (_isRefreshingHomeData) return;

    _isRefreshingHomeData = true;
    try {
      await Future.wait<void>([
        _shopController.fetchNearbyShops(),
        _shopController.fetchRecommendedShops(),
      ]);
    } finally {
      _isRefreshingHomeData = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mutationSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantModel> _filterRestaurants(List<RestaurantModel> items) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((restaurant) {
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.subtitle.toLowerCase().contains(query) ||
          restaurant.distance.toLowerCase().contains(query) ||
          restaurant.address.toLowerCase().contains(query) ||
          restaurant.openingHours.toLowerCase().contains(query) ||
          restaurant.popularDishes.any(
            (dish) => dish.toLowerCase().contains(query),
          );
    }).toList();
  }

  List<HomeRecommendationItemModel> _filterRecommended(
    List<HomeRecommendationItemModel> items,
  ) {
    final String query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      return item.title.toLowerCase().contains(query) ||
          item.distance.toLowerCase().contains(query) ||
          item.openingHours.toLowerCase().contains(query) ||
          (item.rating > 0 && item.rating.toStringAsFixed(1).contains(query)) ||
          (item.restaurant?.name.toLowerCase().contains(query) ?? false) ||
          (item.food?.name.toLowerCase().contains(query) ?? false) ||
          (item.food?.description.toLowerCase().contains(query) ?? false) ||
          (item.food?.restaurantName.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        bodyPadding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        body: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: _refreshHomeData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Image.asset(
                    //   AppImages.appLogo,
                    //   width: 32,
                    //   height: 51,
                    //   fit: BoxFit.contain,
                    // ),
                    // Image.asset(
                    //   AppImages.appLogo,
                    //   width: 60,
                    //   height: 60,
                    //   fit: BoxFit.contain,
                    // ),
                    Image.asset(
                      AppImages.appicon,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),

                    const Spacer(),
                    InkWell(
                      onTap: _openEvents,
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
                            Text(
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
                    color: AppColors.primaryText(context),
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
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
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
                                fontWeight: FontWeight.w400,
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
                                  fontWeight: FontWeight.w300,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 52,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(9),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                            FocusScope.of(context).unfocus();
                          },
                          child: Center(
                            child: Image.asset(
                              AppImages.search,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        active: true,
                        icon: AppImages.all,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Restaurant List',
                        icon: AppImages.restaurantlist,
                        onTap: _openRestaurantList,
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Food List',
                        icon: AppImages.foodlist,
                        onTap: _openFoodList,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: 'Nearby Restaurants',
                  subtitle: '(within 10km)',
                  onSeeAll: _openRestaurantList,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final bool isLoading = _shopController.isLoading.value;
                  final String error = _shopController.error.value;
                  final List<RestaurantModel> source = _shopController.shops
                      .take(3)
                      .toList();
                  final List<RestaurantModel> filteredRestaurants =
                      _filterRestaurants(source);

                  return SizedBox(
                    height: 224,
                    child: isLoading && source.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : source.isEmpty
                        ? Center(
                            child: Text(
                              error.isNotEmpty
                                  ? 'Could not load restaurants'
                                  : 'No restaurants available',
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          )
                        : filteredRestaurants.isEmpty
                        ? Center(
                            child: Text(
                              'No matching restaurants found',
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredRestaurants.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, index) {
                              final RestaurantModel restaurant =
                                  filteredRestaurants[index];
                              return _NearbyCard(
                                restaurant: restaurant,
                                onTap: () => _openRestaurantDetails(restaurant),
                              );
                            },
                          ),
                  );
                }),
                const SizedBox(height: 18),
                _OnlyTitleHeader(
                  title: 'Recommended for you',
                  onSeeAll: _openRecommendedList,
                ),
                const SizedBox(height: 10),
                Obx(() {
                  final bool isRecommendedLoading =
                      _shopController.isRecommendedLoading.value;
                  final String recommendedError =
                      _shopController.recommendedError.value;
                  final List<HomeRecommendationItemModel> recommendedItems =
                      _shopController.recommendedItems;

                  final List<HomeRecommendationItemModel> filteredRecommended =
                      _filterRecommended(recommendedItems);

                  final bool hasSearch = _searchQuery.trim().isNotEmpty;
                  final List<HomeRecommendationItemModel> displayRecommended =
                      hasSearch
                      ? filteredRecommended
                      : filteredRecommended.take(5).toList();

                  if (isRecommendedLoading && recommendedItems.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    );
                  }

                  if (recommendedItems.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        recommendedError.isNotEmpty
                            ? 'Could not load recommendations'
                            : 'No recommendations available',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  }

                  if (_searchQuery.trim().isNotEmpty &&
                      filteredRecommended.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No matching recommendations found',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: List<Widget>.generate(displayRecommended.length, (
                      index,
                    ) {
                      final HomeRecommendationItemModel item =
                          displayRecommended[index];

                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == displayRecommended.length - 1
                              ? 0
                              : 10,
                        ),
                        child: _RecommendedItem(
                          item: item,
                          onTap: () => _openRecommendedItem(item),
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openRestaurantList() async {
    await Get.to(() => const RestaurantListScreen());
    if (!mounted) return;
    _refreshHomeData();
  }

  Future<void> _openFoodList() async {
    await Get.to(() => const FoodListScreen());
    if (!mounted) return;
    _refreshHomeData();
  }

  Future<void> _openRecommendedList() async {
    await Get.to(() => const RecommendedListScreen());
    if (!mounted) return;
    _refreshHomeData();
  }

  Future<void> _openEvents() async {
    await Get.to(() => const EventsScreen());
    if (!mounted) return;
    _refreshHomeData();
  }

  Future<void> _openRestaurantDetails(RestaurantModel restaurant) async {
    await Get.to(() => RestaurantDetailsScreen(restaurant: restaurant));
    if (!mounted) return;
    _refreshHomeData();
  }

  Future<void> _openRecommendedItem(HomeRecommendationItemModel item) async {
    if (item.type == 'shop' && item.restaurant != null) {
      await Get.to(() => RestaurantDetailsScreen(shopId: item.restaurant!.id));
      if (!mounted) return;
      _refreshHomeData();
      return;
    }

    if (item.type == 'menu' && item.food != null) {
      await Get.to(() => SingleFoodScreen(menuId: item.food!.id));
      if (!mounted) return;
      _refreshHomeData();
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primaryGreen
              : AppColors.background(context),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: active ? Colors.white : AppColors.primaryText(context),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                  fontFamily: 'Montserrat',
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              color: AppColors.primaryText1(context),
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
  const _OnlyTitleHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.1,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            'See all',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              color: AppColors.primaryText1(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double computedWidth = (screenWidth * 0.45).clamp(148.0, 200.0);

    return SizedBox(
      width: computedWidth,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
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
                        decoration: BoxDecoration(
                          color: AppColors.cardColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: WishlistIcon(
                            type: 'shop',
                            itemId: restaurant.id,
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
                        restaurant.name,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    if (restaurant.rating > 0) ...[
                      Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(
                          color: AppColors.primaryText1(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ] else
                      Text(
                        'No ratings yet',
                        maxLines: 1,
                        softWrap: false,
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
                        style: TextStyle(
                          color: AppColors.primaryText(context),
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
            child: AdaptiveImage(
              path: item.image,
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
                    if (item.rating > 0) ...[
                      Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.primaryText1(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ] else
                      Text(
                        'No ratings yet',
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
