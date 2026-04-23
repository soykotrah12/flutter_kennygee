import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/restaurant_model.dart';

class RestaurantReviewsScreen extends StatelessWidget {
  const RestaurantReviewsScreen({required this.restaurant, super.key});

  final RestaurantModel restaurant;

  static const List<_ReviewItem> _reviews = <_ReviewItem>[
    _ReviewItem(
      name: 'Davide G',
      role: 'Student',
      timeAgo: '2 hours ago',
      message:
          'The food was delicious and well-prepared.\nThe staff were very friendly.',
      likes: 5,
      comments: 5,
      avatar: AppImages.homeRestaurant1,
    ),
    _ReviewItem(
      name: 'Elena C.',
      role: 'Student',
      timeAgo: '2 hours ago',
      message:
          'Great quality for the price. The burger was\njuicy and flavorful.',
      likes: 5,
      comments: 5,
      avatar: AppImages.homeRestaurant2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F3),
      child: AppScaffold(
        useSafeArea: true,
        isScrollable: false,
        backgroundColor: Colors.transparent,
        bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        customAppBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 72,
          titleSpacing: 0,
          automaticallyImplyLeading: true,
          title: Text.rich(
            TextSpan(
              text: 'Reviews ',
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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _ReviewHeroCard(restaurant: restaurant),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ReviewRatingPill(
                        rating: restaurant.rating,
                        reviewsCount: restaurant.reviewsCount,
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
                  const SizedBox(height: 18),
                  ..._reviews.map((item) => _ReviewCard(item: item)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () => _showAddReviewDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.star, color: Colors.white, size: 24),
                label: const Text(
                  'Add A Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: _AddReviewDialogBody(restaurant: restaurant),
          ),
        );
      },
    );
  }
}

class _ReviewHeroCard extends StatelessWidget {
  const _ReviewHeroCard({required this.restaurant});

  final RestaurantModel restaurant;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          AdaptiveImage(
            path: restaurant.image,
            width: double.infinity,
            height: 210,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        restaurant.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColors.primaryOrange,
                    size: 24,
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

class _ReviewRatingPill extends StatelessWidget {
  const _ReviewRatingPill({required this.rating, required this.reviewsCount});

  final double rating;
  final int reviewsCount;

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
          Text(
            '($reviewsCount Reviews)',
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item});

  final _ReviewItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(item.avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.role,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                item.timeAgo,
                style: const TextStyle(
                  color: Color(0xFF9BA0B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            item.message,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_outlined,
                color: Color(0xFF9BA0B8),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${item.likes}',
                style: const TextStyle(
                  color: Color(0xFF9BA0B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.mode_comment_outlined,
                color: Color(0xFF9BA0B8),
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                '${item.comments}',
                style: const TextStyle(
                  color: Color(0xFF9BA0B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddReviewDialogBody extends StatefulWidget {
  const _AddReviewDialogBody({required this.restaurant});

  final RestaurantModel restaurant;

  @override
  State<_AddReviewDialogBody> createState() => _AddReviewDialogBodyState();
}

class _AddReviewDialogBodyState extends State<_AddReviewDialogBody> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(AppImages.defaultProfileImage),
              ),
              const SizedBox(width: 10),
              const Text(
                'Rain Altmann',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List<Widget>.generate(5, (int index) {
              final bool filled = index < _rating;
              return IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  filled ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF2B007),
                  size: 34,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a short review to help fellow food lovers...',
              hintStyle: const TextStyle(
                color: Color(0xFF8F8F8F),
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFFC9C9C9),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewItem {
  const _ReviewItem({
    required this.name,
    required this.role,
    required this.timeAgo,
    required this.message,
    required this.likes,
    required this.comments,
    required this.avatar,
  });

  final String name;
  final String role;
  final String timeAgo;
  final String message;
  final int likes;
  final int comments;
  final String avatar;
}
