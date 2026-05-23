import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/create_shop_request_model.dart';
import '../../data/model/create_shop_response_model.dart';
import '../../data/repo/create_shop_repo.dart';

CreateEventController ensureCreateEventController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<AuthStorageService>()) {
    Get.lazyPut<AuthStorageService>(() => AuthStorageService(), fenix: true);
  }

  if (!Get.isRegistered<CreateShopRepository>()) {
    Get.lazyPut<CreateShopRepository>(
      () => CreateShopRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  if (!Get.isRegistered<CreateEventController>()) {
    Get.put<CreateEventController>(
      CreateEventController(
        Get.find<CreateShopRepository>(),
        Get.find<AuthStorageService>(),
      ),
    );
  }

  return Get.find<CreateEventController>();
}

class CreateEventController extends GetxController {
  CreateEventController(this._repository, this._authStorageService);

  final CreateShopRepository _repository;
  final AuthStorageService _authStorageService;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeRangeController = TextEditingController();
  final TextEditingController entryFeeController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxnString selectedImagePath = RxnString();
  final RxString responseImageUrl = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<CreateShopResponseModel> createdShop = Rxn<CreateShopResponseModel>();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _userId = '';

  static const double platformServiceFee = 29.0;

  @override
  void onInit() {
    super.onInit();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = (await _authStorageService.getUserId() ?? '').trim();
  }

  Future<void> pickImage() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) return;
    selectedImagePath.value = pickedImage.path;
    responseImageUrl.value = '';
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = selectedDate.value ?? now;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;
    selectedDate.value = pickedDate;
    dateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
  }

  Future<void> pickTimeRange(BuildContext context) async {
    final TimeOfDay initialStart = _startTime ?? const TimeOfDay(hour: 16, minute: 0);
    final TimeOfDay? pickedStart = await showTimePicker(
      context: context,
      initialTime: initialStart,
    );

    if (pickedStart == null) return;

    final TimeOfDay initialEnd = _endTime ??
        TimeOfDay(
          hour: (pickedStart.hour + 2) % 24,
          minute: pickedStart.minute,
        );

    final TimeOfDay? pickedEnd = await showTimePicker(
      context: context,
      initialTime: initialEnd,
    );

    if (pickedEnd == null) return;

    _startTime = pickedStart;
    _endTime = pickedEnd;
    timeRangeController.text =
        '${_formatTimeOfDay(pickedStart)} - ${_formatTimeOfDay(pickedEnd)}';
  }

  Future<void> submitCreateShop() async {
    if (isSubmitting.value) return;

    final String title = eventTitleController.text.trim();
    final String description = descriptionController.text.trim();
    final DateTime? eventDate = selectedDate.value;
    final String? imagePath = selectedImagePath.value;

    if (title.isEmpty) {
      _showError('Validation', 'Event title is required.');
      return;
    }

    if (description.isEmpty) {
      _showError('Validation', 'Description is required.');
      return;
    }

    if (imagePath == null || imagePath.trim().isEmpty) {
      _showError('Validation', 'Please add an event photo.');
      return;
    }

    if (eventDate == null) {
      _showError('Validation', 'Please select an event date.');
      return;
    }

    if (_startTime == null || _endTime == null) {
      _showError('Validation', 'Please select a time range.');
      return;
    }

    if (_userId.isEmpty) {
      await _loadUserId();
    }

    if (_userId.isEmpty) {
      _showError('Error', 'Unable to find user id. Please login again.');
      return;
    }

    isSubmitting.value = true;

    final CreateShopRequestModel request = CreateShopRequestModel(
      userId: _userId,
      restaurantName: title,
      description: description,
      imagePath: imagePath,
      address: 'Dhaka',
      longitude: 90.4125,
      latitude: 23.8103,
      eventDate: eventDate,
      openTime: _formatTimeOfDay(_startTime!),
      closeTime: _formatTimeOfDay(_endTime!),
    );

    final result = await _repository.createShop(request: request);

    result.fold(
      (failure) {
        _showError('Create Failed', failure.message);
      },
      (success) {
        createdShop.value = success.data;
        _applyApiResponse(success.data);

        Get.snackbar(
          'Success',
          success.message.isNotEmpty ? success.message : 'Shop created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      },
    );

    isSubmitting.value = false;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final DateTime rawDate = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat('h:mm a').format(rawDate);
  }

  void _applyApiResponse(CreateShopResponseModel response) {
    eventTitleController.text = response.restaurantName;
    descriptionController.text = response.description;

    final DateTime? createdAt = DateTime.tryParse(response.createdAt);
    if (createdAt != null) {
      selectedDate.value = createdAt;
      dateController.text = DateFormat('MM/dd/yyyy').format(createdAt);
    }

    final activeTime = response.firstActiveOperatingDay;
    if (activeTime != null) {
      final String open = activeTime.open.trim();
      final String close = activeTime.close.trim();
      if (open.isNotEmpty && close.isNotEmpty) {
        timeRangeController.text = '$open - $close';
      }
    }

    responseImageUrl.value = response.image.url;
    selectedImagePath.value = null;
  }

  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardAdaptive,
      margin: const EdgeInsets.all(12),
    );
  }

  @override
  void onClose() {
    eventTitleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeRangeController.dispose();
    entryFeeController.dispose();
    super.onClose();
  }
}
