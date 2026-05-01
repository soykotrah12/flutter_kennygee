import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/create_shop_response_model.dart';
import '../../data/model/review_model.dart';
import '../../data/repo/home_review_repo.dart';
import 'owner_shop_controller.dart';

OwnerHomeReviewsController ensureOwnerHomeReviewsController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<HomeReviewRepository>()) {
    Get.lazyPut<HomeReviewRepository>(
      () => HomeReviewRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<OwnerShopController>()) {
    ensureOwnerShopController();
  }

  if (!Get.isRegistered<OwnerHomeReviewsController>()) {
    Get.put<OwnerHomeReviewsController>(
      OwnerHomeReviewsController(
        repository: Get.find<HomeReviewRepository>(),
        ownerShopController: Get.find<OwnerShopController>(),
      ),
    );
  }

  return Get.find<OwnerHomeReviewsController>();
}

class OwnerHomeReviewsController extends GetxController {
  OwnerHomeReviewsController({
    required HomeReviewRepository repository,
    required OwnerShopController ownerShopController,
  }) : _repository = repository,
       _ownerShopController = ownerShopController;

  final HomeReviewRepository _repository;
  final OwnerShopController _ownerShopController;

  final RxList<ReviewModel> reviews = <ReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString shopId = ''.obs;
  Worker? _shopWorker;

  List<ReviewModel> get topTwoReviews => reviews.take(2).toList();

  @override
  void onInit() {
    super.onInit();
    _syncWithCurrentShop();
    _shopWorker = ever<CreateShopResponseModel?>(
      _ownerShopController.ownerShop,
      (_) => _syncWithCurrentShop(),
    );
  }

  Future<void> _syncWithCurrentShop() async {
    final String nextShopId =
        (_ownerShopController.ownerShop.value?.shopId ?? '').trim();
    if (nextShopId.isEmpty) {
      reviews.clear();
      error.value = '';
      shopId.value = '';
      return;
    }

    if (nextShopId == shopId.value && reviews.isNotEmpty) return;
    shopId.value = nextShopId;
    await fetchReviews();
  }

  Future<void> fetchReviews() async {
    final String activeShopId = shopId.value.trim();
    if (activeShopId.isEmpty || isLoading.value) return;

    isLoading.value = true;
    error.value = '';

    final result = await _repository.fetchReviews(shopId: activeShopId);
    result.fold(
      (failure) {
        error.value = failure.message;
        reviews.clear();
      },
      (success) {
        reviews.assignAll(success.data.reviews);
      },
    );

    isLoading.value = false;
  }

  @override
  void onClose() {
    _shopWorker?.dispose();
    super.onClose();
  }
}
