import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/review_model.dart';
import '../../data/repo/home_review_repo.dart';

class HomeReviewController extends GetxController {
  HomeReviewController(this._repository, {required this.targetId});

  final HomeReviewRepository _repository;
  final String targetId;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;
  final RxString error = ''.obs;

  static String tagFor(String targetId) => 'reviews_$targetId';

  static HomeReviewController ensureInitialized(String targetId) {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<HomeReviewRepository>()) {
      Get.lazyPut<HomeReviewRepository>(
        () => HomeReviewRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final String tag = tagFor(targetId);

    if (!Get.isRegistered<HomeReviewController>(tag: tag)) {
      Get.put<HomeReviewController>(
        HomeReviewController(
          Get.find<HomeReviewRepository>(),
          targetId: targetId,
        ),
        tag: tag,
      );
    }

    return Get.find<HomeReviewController>(tag: tag);
  }

  @override
  void onInit() {
    super.onInit();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchReviews(id: targetId);

    result.fold(
      (failure) {
        error.value = failure.message;
      },
      (success) {
        reviews.assignAll(success.data);
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
}
