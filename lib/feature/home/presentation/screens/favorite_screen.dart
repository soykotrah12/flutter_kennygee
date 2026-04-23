import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

enum _FavoriteTab { all, restaurant, food }

enum _FavoriteItemType { restaurant, food }

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  _FavoriteTab _activeTab = _FavoriteTab.all;

  static const List<_FavoriteItem> _items = <_FavoriteItem>[
    _FavoriteItem(
      type: _FavoriteItemType.restaurant,
      image: AppImages.homeRestaurant1,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: true,
    ),
    _FavoriteItem(
      type: _FavoriteItemType.food,
      image: AppImages.homeRestaurant2,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: true,
    ),
    _FavoriteItem(
      type: _FavoriteItemType.food,
      image: AppImages.homeRestaurant3,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: false,
    ),
    _FavoriteItem(
      type: _FavoriteItemType.restaurant,
      image: AppImages.homeRestaurant1,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: true,
    ),
    _FavoriteItem(
      type: _FavoriteItemType.restaurant,
      image: AppImages.homeRestaurant2,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: true,
    ),
    _FavoriteItem(
      type: _FavoriteItemType.food,
      image: AppImages.homeRestaurant3,
      title: 'Side view club',
      rating: 5.0,
      distance: '1.2 miles away',
      openingHours: '11:00 AM - 10:00 PM',
      isLiked: true,
    ),
  ];

  List<_FavoriteItem> get _filteredItems {
    switch (_activeTab) {
      case _FavoriteTab.all:
        return _items;
      case _FavoriteTab.restaurant:
        return _items
            .where((item) => item.type == _FavoriteItemType.restaurant)
            .toList();
      case _FavoriteTab.food:
        return _items
            .where((item) => item.type == _FavoriteItemType.food)
            .toList();
    }
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
        bodyPadding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
        body: Column(
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Search Restaurant, dishes...',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: double.infinity,
                    decoration: const BoxDecoration(
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
                ],
              ),
            ),
            const SizedBox(height: 16),
         Row(
           children: [
             _FavoriteFilterChip(
               label: 'All',
               activeIcon: AppImages.all,
               inactiveIcon: AppImages.allcolored,
               isActive: _activeTab == _FavoriteTab.all,
               onTap: () => setState(() => _activeTab = _FavoriteTab.all),
             ),
             const SizedBox(width: 10),
             _FavoriteFilterChip(
               label: 'Restaurant List',
               activeIcon: AppImages.restaurantlistclored,
               inactiveIcon: AppImages.restaurantlist,
               isActive: _activeTab == _FavoriteTab.restaurant,
               onTap: () =>
                   setState(() => _activeTab = _FavoriteTab.restaurant),
             ),
             const SizedBox(width: 10),
             _FavoriteFilterChip(
               label: 'Food List',
               activeIcon: AppImages.foodlist,
               inactiveIcon: AppImages.foodlist,
               isActive: _activeTab == _FavoriteTab.food,
               onTap: () => setState(() => _activeTab = _FavoriteTab.food),
             ),
           ],
         ),
            const SizedBox(height: 14),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (_, index) {
                  return _FavoriteGridCard(item: _filteredItems[index]);
                },
              ),
            ),
          ],
        ),
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
                    color: isActive ? Colors.white : AppColors.textBlack,
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

  final _FavoriteItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(
                  item.image,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primaryOrange,
                      size: 20,
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
                    item.title,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                const Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 2),
                Text(
                  item.rating.toStringAsFixed(1),
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
                    style: const TextStyle(
                      color: AppColors.textBlack,
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
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
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
                    style: const TextStyle(
                      color: AppColors.textBlack,
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
    );
  }
}

class _FavoriteItem {
  const _FavoriteItem({
    required this.type,
    required this.image,
    required this.title,
    required this.rating,
    required this.distance,
    required this.openingHours,
    this.isLiked = true,
  });

  final _FavoriteItemType type;
  final String image;
  final String title;
  final double rating;
  final String distance;
  final String openingHours;
  final bool isLiked;
}
