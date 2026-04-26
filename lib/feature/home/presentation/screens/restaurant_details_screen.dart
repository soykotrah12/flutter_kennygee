import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/restaurant_model.dart';
import '../controller/home_shop_details_controller.dart';
import 'restaurant_reviews_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({required this.restaurant, super.key});

  final RestaurantModel restaurant;

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  late final HomeShopDetailsController _detailsController;

  int selectedDishIndex = 0;

  @override
  void initState() {
    super.initState();
    _detailsController = HomeShopDetailsController.ensureInitialized(
      widget.restaurant.id,
    );
    _detailsController.fetchShopDetails(shopId: widget.restaurant.id);
  }

  RestaurantModel get _currentRestaurant =>
      _detailsController.restaurant.value ?? widget.restaurant;

  @override
  Widget build(BuildContext context) {
    final List<String> dishIcons = [
      'assets/icons/pasta.png',
      'assets/icons/burger.png',
      'assets/icons/cheese.png',
    ];

    return Obx(() {
      final RestaurantModel restaurant = _currentRestaurant;
      final List<String> popularDishes = restaurant.popularDishes.isNotEmpty
          ? restaurant.popularDishes
          : restaurant.menuItems.map((item) => item.name).toList();

      return Container(
        color: const Color(0xFFF3F3F3),
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
                text: 'Details ',
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
                children: const [
                  TextSpan(
                    text: '(within 10km Restaurant)',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      onReviewsTap: () {
                        Get.to(
                          () => RestaurantReviewsScreen(restaurant: restaurant),
                        );
                      },
                    ),
                    const Spacer(),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.bookmark,
                        color: AppColors.primaryGreen,
                        size: 20,
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
                ),
                const SizedBox(height: 26),
                const Text(
                  'Popular Dishes',
                  style: TextStyle(
                    color: AppColors.textBlack,
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
                              selectedDishIndex = index;
                            });
                          },
                          child: _DishChip(
                            label: dish,
                            iconImage: iconImage,
                            isActive: selectedDishIndex == index,
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Text(
                    'No popular dishes available',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                const SizedBox(height: 16),
                if (restaurant.menuItems.isNotEmpty)
                  ...restaurant.menuItems.map(
                    (item) => _MenuItemTile(item: item),
                  )
                else
                  const Text(
                    'No menu items available',
                    style: TextStyle(
                      color: AppColors.textGrey,
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
                        restaurant.name.isNotEmpty
                            ? restaurant.name
                            : 'Restaurant',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        restaurant.subtitle.isNotEmpty
                            ? restaurant.subtitle
                            : 'Restaurant',
                        style: const TextStyle(
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
                  decoration: const BoxDecoration(
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
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primaryGreen, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppColors.primaryOrange, size: 16),
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onReviewsTap,
            child: Text(
              '($reviewsCount Reviews)',
              style: const TextStyle(
                color: AppColors.textBlack,
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
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textBlack,
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
  });

  final String openTime;
  final String closeTime;
  final bool isClosedToday;

  @override
  Widget build(BuildContext context) {
    final List<_OperatingHoursEntry> entries = <_OperatingHoursEntry>[
      _OperatingHoursEntry(
        day: 'Today',
        open: _formatTime(openTime),
        close: _formatTime(closeTime),
        isClosed: isClosedToday,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              color: Color(0xFF2EA84A),
              size: 26,
            ),
            SizedBox(width: 8),
            Text(
              'Operating Hours',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List<Widget>.generate(entries.length, (int index) {
              final _OperatingHoursEntry entry = entries[index];
              return Column(
                children: [
                  _OpeningHoursDayRow(entry: entry),
                  if (index != entries.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF0F0F0),
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

  final _OperatingHoursEntry entry;

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
            ? entry.open
            : hasClose
            ? entry.close
            : 'Time unavailable';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: dayColumnWidth,
                child: Text(
                  entry.day,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                          spacing: 10,
                          runSpacing: 8,
                          children: hasOpen && hasClose
                              ? <Widget>[
                                  _OpeningHoursChip(label: entry.open),
                                  const Text(
                                    '\u2014',
                                    style: TextStyle(
                                      color: Color(0xFF13674F),
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  _OpeningHoursChip(label: entry.close),
                                ]
                              : <Widget>[
                                  _OpeningHoursChip(label: singleLabel),
                                ],
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
  const _OpeningHoursChip({
    required this.label,
    this.textColor,
  });

  final String label;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 98),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor ?? AppColors.textBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class _OperatingHoursEntry {
  const _OperatingHoursEntry({
    required this.day,
    required this.isClosed,
    this.open = '',
    this.close = '',
  });

  final String day;
  final bool isClosed;
  final String open;
  final String close;
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
              color: isActive ? Colors.white : AppColors.textBlack,
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
    final String imagePath = item.image.trim().isNotEmpty
        ? item.image
        : AppImages.homeRestaurant1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9C166), width: 1.5),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AdaptiveImage(
              path: imagePath,
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
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Price ',
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                    children: [
                      TextSpan(
                        text: '\$${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
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
              color: Colors.white,
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
