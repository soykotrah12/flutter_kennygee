import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/controllers/wishlist_controller.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/common/widgets/wishlist_icon.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/controller/profile_controller.dart';
import '../../data/model/restaurant_model.dart';
import '../../data/model/review_model.dart';
import '../controller/home_review_controller.dart';

class RestaurantReviewsScreen extends StatefulWidget {
  const RestaurantReviewsScreen({
    required this.restaurant,
    this.shopId,
    this.menuId,
    super.key,
  });

  final RestaurantModel restaurant;
  final String? shopId;
  final String? menuId;

  @override
  State<RestaurantReviewsScreen> createState() =>
      _RestaurantReviewsScreenState();
}

class _RestaurantReviewsScreenState extends State<RestaurantReviewsScreen>
    with WidgetsBindingObserver {
  late final String _targetId;
  late final HomeReviewController _reviewController;
  late final ProfileController _profileController;
  late final ApiClient _apiClient;
  late final WishlistController _wishlistController;
  bool _isBookmarkLoading = false;

  bool get _isMenuReview =>
      widget.menuId != null && widget.menuId!.trim().isNotEmpty;
  bool get _showShopBookmark => !_isMenuReview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _targetId = _resolveTargetId();
    _reviewController = HomeReviewController.ensureInitialized(
      targetId: _targetId,
      isMenuReview: _isMenuReview,
    );
    _profileController = ensureProfileController();
    _apiClient = ApiClient();
    _wishlistController = Get.find<WishlistController>();
    _wishlistController.seedWishlist(
      type: 'shop',
      itemId: (widget.shopId ?? widget.restaurant.id).trim(),
      isWishlisted: widget.restaurant.isLiked,
    );

    if (_profileController.profile.value == null) {
      _profileController.fetchProfile(showLoader: false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final String tag = HomeReviewController.tagFor(
      targetId: _targetId,
      isMenuReview: _isMenuReview,
    );
    if (Get.isRegistered<HomeReviewController>(tag: tag)) {
      Get.delete<HomeReviewController>(tag: tag);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _reviewController.fetchReviews();
    }
  }

  String _resolveTargetId() {
    final String menuId = widget.menuId?.trim() ?? '';
    if (menuId.isNotEmpty) return menuId;

    final String shopId = widget.shopId?.trim() ?? '';
    if (shopId.isNotEmpty) return shopId;

    return widget.restaurant.id;
  }

  Future<void> _toggleShopBookmark() async {
    if (!_showShopBookmark || _isBookmarkLoading) return;

    final String shopId = (widget.shopId ?? widget.restaurant.id).trim();
    if (shopId.isEmpty) return;

    final bool previous = _wishlistController.isWishlisted('shop', shopId);
    setState(() {
      _isBookmarkLoading = true;
    });
    _wishlistController.setWishlisted(
      type: 'shop',
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
          type: 'shop',
          itemId: shopId,
          isWishlisted: previous,
        );
        setState(() {
          _isBookmarkLoading = false;
        });
        Get.snackbar(
          'Bookmark Failed',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
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
          type: 'shop',
          itemId: shopId,
          isWishlisted: resolvedState,
        );
        setState(() {
          _isBookmarkLoading = false;
        });
      },
    );
  }

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
            const TextSpan(
              text: 'Reviews ',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
              children: [
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
        body: Obx(() {
          final List<ReviewModel> reviews = _reviewController.reviews;
          final bool isLoading = _reviewController.isLoading.value;
          final int reviewCount = _reviewController.totalReviews.value > 0
              ? _reviewController.totalReviews.value
              : reviews.isNotEmpty
              ? reviews.length
              : widget.restaurant.reviewsCount;
          final double averageRating = _reviewController.averageRating.value > 0
              ? _reviewController.averageRating.value
              : widget.restaurant.rating;
          final String shopId = (widget.shopId ?? widget.restaurant.id).trim();
          final bool isShopBookmarked = _wishlistController.isWishlisted(
            'shop',
            shopId,
          );
          _wishlistController.seedWishlist(
            type: 'shop',
            itemId: shopId,
            isWishlisted: widget.restaurant.isLiked,
          );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _ReviewHeroCard(restaurant: widget.restaurant),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ReviewRatingPill(
                          rating: averageRating,
                          reviewsCount: reviewCount,
                        ),
                        if (_showShopBookmark) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: _isBookmarkLoading
                                ? null
                                : _toggleShopBookmark,
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
                                  ? const Padding(
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
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (isLoading && reviews.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    else if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          _reviewController.error.value.isNotEmpty
                              ? _reviewController.error.value
                              : 'No reviews yet',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    else
                      ...reviews.map(
                        (item) => _ReviewCard(
                          item: item,
                          reviewController: _reviewController,
                        ),
                      ),
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
          );
        }),
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
            child: _AddReviewDialogBody(
              profileController: _profileController,
              reviewController: _reviewController,
              isMenuReview: _isMenuReview,
              shopId: (widget.shopId ?? widget.restaurant.id).trim(),
              menuId: widget.menuId?.trim(),
            ),
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
                  child: Center(
                    child: WishlistIcon(
                      type: 'shop',
                      itemId: restaurant.id,
                      initiallyWishlisted: restaurant.isLiked,
                      color: AppColors.primaryOrange,
                      size: 24,
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
  const _ReviewCard({required this.item, required this.reviewController});

  final ReviewModel item;
  final HomeReviewController reviewController;

  @override
  Widget build(BuildContext context) {
    final String avatar = item.reviewerImage.trim().isNotEmpty
        ? item.reviewerImage
        : AppImages.defaultProfileImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 26, backgroundImage: _imageProvider(avatar)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.reviewerName,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.reviewerRole,
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
                _timeAgo(item.createdAt),
                style: const TextStyle(
                  color: Color(0xFF9BA0B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(5, (int index) {
              final bool filled = index < item.rating.round();
              return Icon(
                filled ? Icons.star : Icons.star_border,
                color: const Color(0xFFF2B007),
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            item.reviewText,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 15,
              height: 1.4,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 18),
          Obx(() {
            final int liveIndex = reviewController.reviews.indexWhere(
              (review) => review.id.trim() == item.id.trim(),
            );
            final ReviewModel liveItem = liveIndex >= 0
                ? reviewController.reviews[liveIndex]
                : item;
            final bool isLiked = reviewController.isReviewLiked(liveItem.id);
            final bool isLikeLoading = reviewController.isReviewLikeLoading(
              liveItem.id,
            );

            return IgnorePointer(
              ignoring: isLikeLoading,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => reviewController.toggleReviewLike(liveItem.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked
                          ? Icons.thumb_up_alt
                          : Icons.thumb_up_alt_outlined,
                      color: const Color(0xFF9BA0B8),
                      size: 22,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${liveItem.likes}',
                      style: const TextStyle(
                        color: Color(0xFF9BA0B8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AddReviewDialogBody extends StatefulWidget {
  const _AddReviewDialogBody({
    required this.profileController,
    required this.reviewController,
    required this.isMenuReview,
    required this.shopId,
    this.menuId,
  });

  final ProfileController profileController;
  final HomeReviewController reviewController;
  final bool isMenuReview;
  final String shopId;
  final String? menuId;

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
          Obx(() {
            final profile = widget.profileController.profile.value;
            final String userName = (profile?.name ?? '').trim().isNotEmpty
                ? profile!.name
                : 'User';
            final String userImage = profile?.profileImage.url ?? '';

            return Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage: _imageProvider(
                    userImage.trim().isNotEmpty
                        ? userImage
                        : AppImages.defaultProfileImage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            );
          }),
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
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.reviewController.isPosting.value
                          ? null
                          : _onPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: widget.reviewController.isPosting.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
            );
          }),
        ],
      ),
    );
  }

  Future<void> _onPost() async {
    final String reviewText = _controller.text.trim();
    final profile = widget.profileController.profile.value;
    final String reviewerName = (profile?.name ?? '').trim().isNotEmpty
        ? profile!.name
        : 'User';
    final String reviewerRole = (profile?.role ?? '').trim().isNotEmpty
        ? profile!.role
        : 'User';
    final String reviewerImage = profile?.profileImage.url ?? '';

    if (_rating <= 0) {
      Get.snackbar(
        'Validation',
        'Please provide a rating.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }

    if (reviewText.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please write a review.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }

    final String message = await widget.reviewController.postReview(
      shopId: widget.isMenuReview ? null : widget.shopId,
      menuId: widget.isMenuReview ? widget.menuId : null,
      rating: _rating,
      reviewText: reviewText,
      reviewerName: reviewerName,
      reviewerRole: reviewerRole,
      reviewerImage: reviewerImage,
    );

    if (!mounted) return;

    if (message.toLowerCase().contains('success')) {
      Navigator.of(context).pop();
      Get.snackbar(
        'Success',
        'Review posted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      'Post Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
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

  final DateTime now = DateTime.now();
  final Duration diff = now.difference(parsed);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} hours ago';
  if (diff.inDays < 30) return '${diff.inDays} days ago';

  final int months = (diff.inDays / 30).floor();
  if (months < 12) return '$months months ago';

  final int years = (months / 12).floor();
  return '$years years ago';
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
