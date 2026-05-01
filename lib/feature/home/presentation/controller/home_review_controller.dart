import 'package:get/get.dart';
import 'dart:async';

import '../../../../core/network/api_client.dart';
import '../../data/model/review_model.dart';
import '../../data/repo/home_review_repo.dart';

class HomeReviewController extends GetxController {
  HomeReviewController(
    this._repository, {
    required this.targetId,
    required this.isMenuReview,
  });

  final HomeReviewRepository _repository;
  final String targetId;
  final bool isMenuReview;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxDouble averageRating = 0.0.obs;
  final RxInt totalReviews = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxString error = ''.obs;
  final RxSet<String> likedReviewIds = <String>{}.obs;
  final RxSet<String> likingReviewIds = <String>{}.obs;
  StreamSubscription<ApiMutationEvent>? _mutationSubscription;

  static String tagFor({required String targetId, required bool isMenuReview}) {
    final String type = isMenuReview ? 'menu' : 'shop';
    return 'reviews_${type}_$targetId';
  }

  static HomeReviewController ensureInitialized({
    required String targetId,
    required bool isMenuReview,
  }) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeReviewRepository>()) {
      Get.lazyPut<HomeReviewRepository>(
        () => HomeReviewRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagFor(targetId: targetId, isMenuReview: isMenuReview);

    if (!Get.isRegistered<HomeReviewController>(tag: tag)) {
      Get.put<HomeReviewController>(
        HomeReviewController(
          Get.find<HomeReviewRepository>(),
          targetId: targetId,
          isMenuReview: isMenuReview,
        ),
        tag: tag,
      );
    }

    return Get.find<HomeReviewController>(tag: tag);
  }

  @override
  void onInit() {
    super.onInit();
    _mutationSubscription = ApiClient.mutationStream.listen((event) {
      if (_shouldRefresh(event)) {
        fetchReviews();
      }
    });
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchReviews(
      shopId: isMenuReview ? null : targetId,
      menuId: isMenuReview ? targetId : null,
    );

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        reviews.assignAll(success.data.reviews);
        final Set<String> liked = success.data.reviews
            .where((review) => review.isLiked)
            .map((review) => review.id.trim())
            .where((id) => id.isNotEmpty)
            .toSet();
        likedReviewIds
          ..clear()
          ..addAll(liked);
        averageRating.value = success.data.averageRating;
        totalReviews.value = success.data.totalReviews;
      },
    );

    isLoading.value = false;
  }

  Future<String> postReview({
    String? shopId,
    String? menuId,
    required int rating,
    required String reviewText,
    required String reviewerName,
    required String reviewerRole,
    required String reviewerImage,
  }) async {
    if (isPosting.value) return '';

    isPosting.value = true;

    final result = await _repository.createReview(
      shopId: shopId,
      menuId: menuId,
      rating: rating,
      reviewText: reviewText,
    );

    String message = '';

    result.fold(
      (failure) {
        message = failure.message;
      },
      (success) {
        message = 'Review posted successfully';
        final int currentCount = totalReviews.value;
        final double currentAverage = averageRating.value;
        totalReviews.value = currentCount + 1;
        averageRating.value = currentCount <= 0
            ? rating.toDouble()
            : ((currentAverage * currentCount) + rating) / (currentCount + 1);
        reviews.insert(
          0,
          success.data.copyWith(
            rating: rating.toDouble(),
            reviewText: reviewText,
            reviewerName: reviewerName,
            reviewerRole: reviewerRole,
            reviewerImage: reviewerImage,
          ),
        );
      },
    );

    isPosting.value = false;
    return message;
  }

  bool isReviewLiked(String reviewId) {
    final String id = reviewId.trim();
    if (id.isEmpty) return false;
    return likedReviewIds.contains(id);
  }

  bool isReviewLikeLoading(String reviewId) {
    final String id = reviewId.trim();
    if (id.isEmpty) return false;
    return likingReviewIds.contains(id);
  }

  Future<void> toggleReviewLike(String reviewId) async {
    final String id = reviewId.trim();
    if (id.isEmpty || likingReviewIds.contains(id)) return;

    final int reviewIndex = reviews.indexWhere((item) => item.id.trim() == id);
    if (reviewIndex < 0) return;

    final ReviewModel previousItem = reviews[reviewIndex];
    final bool wasLiked = likedReviewIds.contains(id);
    final int previousLikes = previousItem.likes;
    final int nextLikes = wasLiked
        ? (previousLikes > 0 ? previousLikes - 1 : 0)
        : previousLikes + 1;

    if (wasLiked) {
      likedReviewIds.remove(id);
    } else {
      likedReviewIds.add(id);
    }
    reviews[reviewIndex] = previousItem.copyWith(
      likes: nextLikes,
      isLiked: !wasLiked,
    );
    reviews.refresh();

    likingReviewIds.add(id);

    final result = await _repository.toggleReviewLike(reviewId: id);
    result.fold(
      (_) {
        if (wasLiked) {
          likedReviewIds.add(id);
        } else {
          likedReviewIds.remove(id);
        }
        final int restoreIndex = reviews.indexWhere(
          (item) => item.id.trim() == id,
        );
        if (restoreIndex >= 0) {
          reviews[restoreIndex] = previousItem;
          reviews.refresh();
        }
      },
      (success) {
        final String message = success.message.toLowerCase();
        final Map<String, dynamic> payload = _asMap(success.data);
        final Map<String, dynamic> result = _asMap(
          payload['result'] ?? payload['review'] ?? payload['data'],
        );
        final dynamic likedValue =
            result['isLiked'] ??
            result['liked'] ??
            result['isLikedByCurrentUser'] ??
            result['likedByCurrentUser'] ??
            payload['isLiked'] ??
            payload['liked'] ??
            payload['isLikedByCurrentUser'] ??
            payload['likedByCurrentUser'];
        bool resolvedLiked = _toBoolOrNull(likedValue) ?? !wasLiked;
        if (message.contains('dislike') ||
            message.contains('unlike') ||
            message.contains('removed')) {
          resolvedLiked = false;
        } else if (message.contains('like') || message.contains('added')) {
          resolvedLiked = true;
        }

        if (resolvedLiked) {
          likedReviewIds.add(id);
        } else {
          likedReviewIds.remove(id);
        }

        final int currentIndex = reviews.indexWhere(
          (item) => item.id.trim() == id,
        );
        if (currentIndex >= 0) {
          final ReviewModel currentItem = reviews[currentIndex];
          final int? serverLikes = _toIntOrNull(
            result['likes'] ??
                result['likeCount'] ??
                payload['likes'] ??
                payload['likeCount'],
          );
          final int resolvedLikes = resolvedLiked
              ? (wasLiked ? previousLikes : previousLikes + 1)
              : (wasLiked
                    ? (previousLikes > 0 ? previousLikes - 1 : 0)
                    : previousLikes);
          reviews[currentIndex] = currentItem.copyWith(
            likes: serverLikes ?? resolvedLikes,
            isLiked: resolvedLiked,
          );
          reviews.refresh();
        }
      },
    );

    likingReviewIds.remove(id);
  }

  bool _shouldRefresh(ApiMutationEvent event) {
    final String endpoint = event.endpoint.toLowerCase();
    if (!endpoint.contains('/review')) return false;
    if (endpoint.contains('/review/like/')) return false;
    final dynamic payload = event.data;
    if (payload is Map<String, dynamic>) {
      final String eventShopId = (payload['shopId'] ?? '').toString().trim();
      final String eventMenuId = (payload['menuId'] ?? '').toString().trim();
      if (isMenuReview) {
        return eventMenuId.isEmpty || eventMenuId == targetId;
      }
      return eventShopId.isEmpty || eventShopId == targetId;
    }
    return true;
  }

  @override
  void onClose() {
    _mutationSubscription?.cancel();
    super.onClose();
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

bool? _toBoolOrNull(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String raw = value.toString().trim().toLowerCase();
  if (raw.isEmpty) return null;
  if (raw == 'true' || raw == '1' || raw == 'yes') return true;
  if (raw == 'false' || raw == '0' || raw == 'no') return false;
  return null;
}

int? _toIntOrNull(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
