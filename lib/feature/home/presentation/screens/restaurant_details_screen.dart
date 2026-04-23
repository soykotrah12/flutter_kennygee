import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/restaurant_model.dart';
import 'restaurant_reviews_screen.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  const RestaurantDetailsScreen({required this.restaurant, super.key});

  final RestaurantModel restaurant;

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  int selectedDishIndex = 0;
  @override
  Widget build(BuildContext context) {
    final List<String> dishes = widget.restaurant.popularDishes;
    final List<RestaurantMenuItemModel> menuItems = widget.restaurant.menuItems;
    final List<String> dishIcons = [
      'assets/icons/pasta.png',
      'assets/icons/burger.png',
      'assets/icons/cheese.png',
    ];

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
              _HeroCard(restaurant: widget.restaurant),
              const SizedBox(height: 16),
              Row(
                children: [
                  _RatingPill(
                    rating: widget.restaurant.rating,
                    reviewsCount: widget.restaurant.reviewsCount,
                    onReviewsTap: () {
                      Get.to(
                        () => RestaurantReviewsScreen(restaurant: widget.restaurant),
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
                value: widget.restaurant.address.isNotEmpty
                    ? widget.restaurant.address
                    : widget.restaurant.distance,
              ),
              const SizedBox(height: 18),
              _InfoRow(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFF39B45A),
                title: 'Opening Hours',
                value: widget.restaurant.openingHours.isNotEmpty
                    ? widget.restaurant.openingHours
                    : 'Not available',
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
              if (widget.restaurant.popularDishes.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.restaurant.popularDishes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                 itemBuilder: (_, index) {
  final String dish = widget.restaurant.popularDishes[index];

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
              if (widget.restaurant.menuItems.isNotEmpty)
                ...widget.restaurant.menuItems.map((item) => _MenuItemTile(item: item))
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
          Image.asset(
            restaurant.image,
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
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primaryOrange,
                    size: 16,
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
            child: Image.asset(
              item.image,
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
            child: Icon(
              item.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 18,
              color: AppColors.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}
