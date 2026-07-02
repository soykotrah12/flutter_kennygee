import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/google_nearby_restaurant_model.dart';
import '../controller/google_nearby_restaurant_controller.dart';
import '../widgets/google_nearby_restaurant_card.dart';
import 'google_restaurant_details_screen.dart';

class GoogleNearbyRestaurantsScreen extends StatefulWidget {
  const GoogleNearbyRestaurantsScreen({super.key});

  @override
  State<GoogleNearbyRestaurantsScreen> createState() =>
      _GoogleNearbyRestaurantsScreenState();
}

class _GoogleNearbyRestaurantsScreenState
    extends State<GoogleNearbyRestaurantsScreen> {
  late final GoogleNearbyRestaurantController _controller;
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _controller = GoogleNearbyRestaurantController.ensureInitialized();
    _searchController = TextEditingController(
      text: _controller.searchQuery.value,
    );
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double current = _scrollController.position.pixels;
    if (maxScroll - current <= 220) {
      _controller.loadNextPage();
    }
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
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        customAppBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 72,
          titleSpacing: 0,
          title: Text(
            'Google Nearby Restaurants',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchField(
              controller: _searchController,
              onChanged: _controller.onSearchChanged,
            ),
            const SizedBox(height: 12),
            _FilterBar(controller: _controller),
            const SizedBox(height: 12),
            Obx(() {
              final int visibleCount = _controller.displayedRestaurants.length;
              final int filteredCount = _controller.filteredRestaurants.length;
              final int totalCount = filteredCount > 0
                  ? filteredCount
                  : _controller.effectiveTotalCount;
              if (_controller.isLoading.value && visibleCount == 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Showing $visibleCount of $totalCount restaurants',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                final bool isLoading = _controller.isLoading.value;
                final bool isLoadingMore = _controller.isLoadingMore.value;
                final String error = _controller.error.value;
                final List<GoogleNearbyRestaurantModel> items =
                    _controller.displayedRestaurants;

                if (isLoading && _controller.restaurants.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _controller.refreshRestaurants,
                    child: _RefreshableState(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                }

                if (error.isNotEmpty && _controller.restaurants.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _controller.refreshRestaurants,
                    child: _RefreshableState(
                      child: Text(
                        'Could not load Google nearby restaurants',
                        textAlign: TextAlign.center,
                        style: _stateTextStyle(context),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primaryGreen,
                    onRefresh: _controller.refreshRestaurants,
                    child: _RefreshableState(
                      child: Text(
                        'No nearby Google restaurants available',
                        textAlign: TextAlign.center,
                        style: _stateTextStyle(context),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primaryGreen,
                  onRefresh: _controller.refreshRestaurants,
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: items.length + (isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      if (index >= items.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        );
                      }

                      final GoogleNearbyRestaurantModel restaurant =
                          items[index];
                      return GoogleNearbyRestaurantCard(
                        restaurant: restaurant,
                        compact: true,
                        onTap: () => Get.to(
                          () => GoogleRestaurantDetailsScreen(
                            restaurant: restaurant,
                          ),
                        ),
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

  TextStyle _stateTextStyle(BuildContext context) {
    return TextStyle(
      color: AppColors.secondaryText(context),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamily: 'Montserrat',
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryGreen, width: 1.1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: AppColors.secondaryText(context),
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primaryText1(context),
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
              ),
              decoration: InputDecoration(
                hintText: 'Search Google restaurants...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox(width: 8);
              return IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.secondaryText(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final GoogleNearbyRestaurantController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _RadiusMenu(controller: controller),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: '3+',
              active: controller.minimumRating.value == 3,
              onTap: () => controller.setMinimumRating(
                controller.minimumRating.value == 3 ? 0 : 3,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: '4+',
              active: controller.minimumRating.value == 4,
              onTap: () => controller.setMinimumRating(
                controller.minimumRating.value == 4 ? 0 : 4,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: '4.5+',
              active: controller.minimumRating.value == 4.5,
              onTap: () => controller.setMinimumRating(
                controller.minimumRating.value == 4.5 ? 0 : 4.5,
              ),
            ),
            const SizedBox(width: 8),
            _FilterChipButton(
              label: 'Open now',
              active: controller.openNowOnly.value,
              icon: Icons.schedule_rounded,
              onTap: controller.toggleOpenNowOnly,
            ),
          ],
        ),
      );
    });
  }
}

class _RadiusMenu extends StatelessWidget {
  const _RadiusMenu({required this.controller});

  final GoogleNearbyRestaurantController controller;

  @override
  Widget build(BuildContext context) {
    const Map<int, String> radiusLabels = <int, String>{
      1000: '1km',
      3000: '3km',
      5000: '5km',
      10000: '10km',
    };

    return PopupMenuButton<int>(
      onSelected: controller.setRadius,
      color: AppColors.cardColor(context),
      itemBuilder: (context) => radiusLabels.entries.map((entry) {
        return PopupMenuItem<int>(
          value: entry.key,
          child: Text(
            entry.value,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontFamily: 'Montserrat',
            ),
          ),
        );
      }).toList(),
      child: _FilterChipButton(
        label: radiusLabels[controller.radiusMeters.value] ?? '10km',
        active: true,
        icon: Icons.tune_rounded,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    this.active = false,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: active ? Colors.white : AppColors.primaryText(context),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : AppColors.primaryText(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
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
          height: MediaQuery.sizeOf(context).height * 0.58,
          child: Center(child: child),
        ),
      ],
    );
  }
}
