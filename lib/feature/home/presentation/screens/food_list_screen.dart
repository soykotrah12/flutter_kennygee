import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class FoodListScreen extends StatelessWidget {
  const FoodListScreen({super.key});

  static final List<_FoodItem> _items = [
    const _FoodItem(image: AppImages.homeRestaurant2, isLiked: true),
    const _FoodItem(image: AppImages.homeRestaurant3, isLiked: true),
    const _FoodItem(image: AppImages.homeRestaurant1, isLiked: true),
    const _FoodItem(image: AppImages.homeRestaurant2, isLiked: false),
    const _FoodItem(image: AppImages.homeRestaurant3, isLiked: true),
    const _FoodItem(image: AppImages.homeRestaurant1, isLiked: false),
  ];

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
              style: const TextStyle(
                color: AppColors.textBlack,
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
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (_, index) => _FoodGridCard(item: _items[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodGridCard extends StatelessWidget {
  const _FoodGridCard({required this.item});

  final _FoodItem item;

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
                  height: 184,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: AppColors.primaryOrange,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Side view club',
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                Icon(Icons.star, size: 16, color: AppColors.primaryOrange),
                SizedBox(width: 2),
                Text(
                  '5.0',
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
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 2, 12, 0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primaryOrange,
                  size: 24,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '1.2 miles away',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF31B24C),
                  size: 24,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '11:00 AM - 10:00 PM',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textBlack,
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
    );
  }
}

class _FoodItem {
  const _FoodItem({required this.image, required this.isLiked});

  final String image;
  final bool isLiked;
}
