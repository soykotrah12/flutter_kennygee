import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/review_model.dart';
import '../../create_event/presentation/screens/create_event_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../controller/owner_home_reviews_controller.dart';
import '../controller/owner_shop_controller.dart';
import 'owner_upgrade_plan_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  late final OwnerHomeReviewsController _reviewsController;
  late final OwnerShopController _ownerShopController;

  @override
  void initState() {
    super.initState();
    _reviewsController = ensureOwnerHomeReviewsController();
    _ownerShopController = ensureOwnerShopController();
  }

  void _showBoostNowDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(
        alpha: 0.2,
      ), // optional dark overlay
      builder: (context) {
        return Stack(
          children: [
            ///  Blur Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.black.withValues(alpha: 0), // must be present
              ),
            ),

            ///  Your Dialog
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90), // adjust as needed
                child: const _BoostNowDialog(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final isCompact = width < 380;
    // final heroSize = isCompact ? 22.0 : 36.0;
    // final actionTextSize = isCompact ? 16.0 : 18.0;
    // final ctaTextSize = isCompact ? 16.0 : 20.0;

    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.background(context),
      bodyPadding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.appLogo,
                width: 32,
                height: 51,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              InkWell(
                onTap: () => Get.to(() => const ProfileScreen()),
                borderRadius: BorderRadius.circular(23),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryGreen,
                      width: 1.2,
                    ),
                    image: const DecorationImage(
                      image: AssetImage(AppImages.ownerOnboarding1),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back,\nThe Culinary Architect',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.9,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Expanded(
              //   child: SecondaryButton(
              //     onPressed: () => _showBoostNowDialog(context),
              //     text: 'Boost Now',
              //     height: 51,
              //     borderRadius: 8,
              //   ),
              // ),
              // const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  onPressed: () => Get.to(() => const CreateEventScreen()),
                  height: 51,
                  borderRadius: 8,
                  child: Text(
                    'Add Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatsCard(
                  icon: AppImages.starIcon,
                  iconColor: AppColors.primaryOrange,
                  title: 'Average Rating',
                  value: '4.8',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  icon: AppImages.reviewIcon,
                  iconColor: const Color(0xFF34B58A),
                  title: 'Total Reviews',
                  value: '1,240',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      AppImages.activePlanIcon,
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Active Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Basic Promotion',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$129/month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  onPressed: () => Get.to(() => const OwnerUpgradePlanScreen()),
                  text: 'Upgrade Plan',
                  height: 48,
                  borderRadius: 8,
                  backgroundColor: AppColors.cardColor(context),
                  textColor: AppColors.primaryGreen,
                  borderColor: Colors.transparent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Recent Reviews',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Obx(() {
                final bool hasReviews = _reviewsController.reviews.isNotEmpty;
                return InkWell(
                  onTap: hasReviews
                      ? () => Get.to(() => const OwnerAllReviewsScreen())
                      : null,
                  child: Text(
                    'View all',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: hasReviews
                          ? AppColors.primaryGreen
                          : AppColors.secondaryText(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            final bool isLoading = _reviewsController.isLoading.value;
            final String error = _reviewsController.error.value;
            final List<ReviewModel> preview = _reviewsController.topTwoReviews;
            final String shopImage =
                (_ownerShopController.ownerShop.value?.image.url ?? '').trim();

            if (isLoading && preview.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                ),
              );
            }

            if (preview.isEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  error.isNotEmpty ? error : 'No reviews yet',
                  style: TextStyle(
                    color: AppColors.secondaryText(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }

            return Column(
              children: List<Widget>.generate(preview.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == preview.length - 1 ? 0 : 14,
                  ),
                  child: _ReviewCard(
                    item: preview[index],
                    bannerImage: shopImage,
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class OwnerAllReviewsScreen extends StatelessWidget {
  const OwnerAllReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OwnerHomeReviewsController reviewsController =
        ensureOwnerHomeReviewsController();
    final OwnerShopController ownerShopController = ensureOwnerShopController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      customAppBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: Text(
          'All Reviews',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      body: Obx(() {
        final List<ReviewModel> reviews = reviewsController.reviews;
        final bool isLoading = reviewsController.isLoading.value;
        final String error = reviewsController.error.value;
        final String shopImage =
            (ownerShopController.ownerShop.value?.image.url ?? '').trim();

        if (isLoading && reviews.isEmpty) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (reviews.isEmpty) {
          return Center(
            child: Text(
              error.isNotEmpty ? error : 'No reviews yet',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) =>
              _ReviewCard(item: reviews[index], bannerImage: shopImage),
        );
      }),
    );
  }
}

class _BoostNowDialog extends StatelessWidget {
  const _BoostNowDialog();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
        // backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 230,
                  height: 220,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: 16,
                        left: 42,
                        child: Transform.rotate(
                          angle: 0.09,
                          child: Container(
                            width: 152,
                            height: 174,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8E8CB),
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        child: Container(
                          width: 162,
                          height: 188,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow(
                                  context,
                                  light: 0.14,
                                  dark: 0.3,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              AppImages.boostImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 26,
                        bottom: 12,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Color(0xFFF3A61F),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            size: 20,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Skyrocket Your\nVisibility',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Boost your restaurant for 7 days. Your best dishes will be featured directly on potential customers home screens, driving more traffic and orders.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                PrimaryButton(
                  onPressed: () => Navigator.of(context).pop(),
                  height: 46,
                  borderRadius: 8,
                  child: Text(
                    'Upgrade & Boost Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 18, 0, 20),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Maybe Later',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final String icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(icon, width: 16, height: 16, color: iconColor),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.secondaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.item, required this.bannerImage});

  final ReviewModel item;
  final String bannerImage;

  @override
  Widget build(BuildContext context) {
    final String topImage = bannerImage.isNotEmpty
        ? bannerImage
        : AppImages.homeRestaurant1;
    final String profileImage = item.reviewerImage.trim().isNotEmpty
        ? item.reviewerImage
        : AppImages.ownerOnboarding1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AdaptiveImage(
              path: topImage,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _imageProvider(profileImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.reviewerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.primaryText(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _timeAgo(item.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.secondaryText(context),
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List<Widget>.generate(5, (int index) {
                          final bool filled = index < item.rating.round();
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            size: 12,
                            color: Colors.amberAccent,
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.reviewText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
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

ImageProvider _imageProvider(String path) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return NetworkImage(path);
  }
  return AssetImage(path);
}

String _timeAgo(String rawDate) {
  final DateTime? parsed = DateTime.tryParse(rawDate);
  if (parsed == null) return 'Just now';

  final Duration diff = DateTime.now().difference(parsed);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hours ago';
  if (diff.inDays < 30) return '${diff.inDays} days ago';

  final int months = (diff.inDays / 30).floor();
  if (months < 12) return '$months months ago';

  final int years = (months / 12).floor();
  return '$years years ago';
}
