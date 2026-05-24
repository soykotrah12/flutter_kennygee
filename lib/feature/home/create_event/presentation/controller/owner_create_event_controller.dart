import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../payment/presentation/controllers/payment_controller.dart';
import '../../../presentation/controller/home_event_controller.dart';
import '../../../presentation/controller/owner_shop_controller.dart';
import '../../../presentation/controller/owner_shop_event_controller.dart';
import '../../data/model/create_event_request_model.dart';
import '../../data/model/create_event_response_model.dart';
import '../../data/repo/create_event_repository.dart';

OwnerCreateEventController ensureOwnerCreateEventController() {
  if (!Get.isRegistered<ApiClient>()) {
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
  }

  if (!Get.isRegistered<CreateEventRepository>()) {
    Get.lazyPut<CreateEventRepository>(
      () => CreateEventRepository(apiClient: Get.find<ApiClient>()),
      fenix: true,
    );
  }

  ensureOwnerShopController();
  ensurePaymentController();

  if (!Get.isRegistered<OwnerCreateEventController>()) {
    Get.put<OwnerCreateEventController>(
      OwnerCreateEventController(Get.find<CreateEventRepository>()),
    );
  }

  return Get.find<OwnerCreateEventController>();
}

class OwnerCreateEventController extends GetxController {
  OwnerCreateEventController(this._repository);

  final CreateEventRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController entryFeeController = TextEditingController();

  final RxBool isSubmitting = false.obs;
  final RxnString selectedImagePath = RxnString();
  final RxString responseImageUrl = ''.obs;
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> selectedTime = Rxn<TimeOfDay>();
  final Rxn<CreateEventResponseModel> createdEvent =
      Rxn<CreateEventResponseModel>();

  static const double defaultPlatformServiceFee = 29.0;

  PaymentController get _paymentController => ensurePaymentController();

  Future<void> pickImage() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
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
      firstDate: DateTime(now.year),
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate == null) return;

    selectedDate.value = pickedDate;
    dateController.text = DateFormat('MM/dd/yyyy').format(pickedDate);
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? const TimeOfDay(hour: 18, minute: 0),
    );

    if (pickedTime == null) return;

    selectedTime.value = pickedTime;
    timeController.text = _formatTimeDisplay(pickedTime);
  }

  Future<void> submitCreateEvent() async {
    if (isSubmitting.value) return;

    final CreateEventRequestModel? request = await _buildValidatedRequest();
    if (request == null) return;

    isSubmitting.value = true;
    final result = await _repository.createEvent(request: request);
    isSubmitting.value = false;

    result.fold(
      (failure) {
        _showError('Create Failed', failure.message);
      },
      (success) {
        _finalizeCreatedEvent(
          event: success.data,
          successMessage: success.message,
        );
      },
    );
  }

  Future<void> submitCreateEventWithPayment() async {
    if (isSubmitting.value || _paymentController.isPaymentLoading.value) return;

    final CreateEventRequestModel? request = await _buildValidatedRequest();
    if (request == null) return;

    isSubmitting.value = true;
    debugPrint('EVENT CREATE PAYLOAD => ${request.toPayload()}');
    debugPrint('EVENT CREATE IMAGE PATH => ${request.imagePath ?? ''}');

    final result = await _repository.createEvent(request: request);
    await result.fold(
      (failure) async {
        debugPrint('EVENT CREATE FAILED => ${failure.message}');
        _showError('Create Failed', failure.message);
      },
      (success) async {
        final String eventId = success.data.eventId.trim();
        debugPrint('CREATE EVENT RESPONSE eventId => $eventId');

        if (eventId.isEmpty) {
          _showError(
            'Create Failed',
            'Event created response is missing event id.',
          );
          return;
        }

        final bool paid = await _paymentController.payForOrder(
          orderId: eventId,
        );
        if (!paid) {
          _showError(
            'Payment',
            _paymentController.paymentMessage.value.isNotEmpty
                ? _paymentController.paymentMessage.value
                : 'Payment was not completed.',
          );
          return;
        }

        _finalizeCreatedEvent(
          event: success.data,
          successMessage: success.message,
          clearFormAfterSuccess: true,
          closeScreenAfterSuccess: true,
        );
      },
    );

    isSubmitting.value = false;
  }

  double get platformServiceFee {
    return createdEvent.value?.platformServiceFee ?? defaultPlatformServiceFee;
  }

  double get total {
    final CreateEventResponseModel? apiEvent = createdEvent.value;
    if (apiEvent != null) return apiEvent.total;

    final double entry = double.tryParse(entryFeeController.text.trim()) ?? 0;
    return entry + defaultPlatformServiceFee;
  }

  Future<CreateEventRequestModel?> _buildValidatedRequest() async {
    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();
    final String entryFeeRaw = entryFeeController.text.trim();
    final DateTime? eventDate = selectedDate.value;
    final TimeOfDay? eventTime = selectedTime.value;
    final String shopId = await _resolveShopId();

    if (shopId.isEmpty) {
      _showError('Validation', 'Please create/select your shop first.');
      return null;
    }
    if (title.isEmpty) {
      _showError('Validation', 'Event title is required.');
      return null;
    }

    if (description.isEmpty) {
      _showError('Validation', 'Description is required.');
      return null;
    }

    if (eventDate == null) {
      _showError('Validation', 'Please select an event date.');
      return null;
    }

    if (eventTime == null) {
      _showError('Validation', 'Please select event time.');
      return null;
    }

    final double? entryFee = double.tryParse(entryFeeRaw);
    if (entryFee == null || entryFee < 0) {
      _showError('Validation', 'Please enter a valid entry fee.');
      return null;
    }

    final double platformServiceFee = this.platformServiceFee;
    final double calculatedTotal = entryFee + platformServiceFee;
    if (platformServiceFee.isNaN ||
        platformServiceFee.isInfinite ||
        platformServiceFee < 0) {
      _showError('Validation', 'Invalid platform service fee.');
      return null;
    }
    if (calculatedTotal.isNaN || calculatedTotal.isInfinite) {
      _showError('Validation', 'Invalid payment total.');
      return null;
    }

    return CreateEventRequestModel(
      shopId: shopId,
      title: title,
      description: description,
      date: eventDate,
      time: _formatTimeApi(eventTime),
      entryFee: entryFee,
      platformServiceFee: platformServiceFee,
      total: calculatedTotal,
      imagePath: selectedImagePath.value,
    );
  }

  Future<String> _resolveShopId() async {
    final OwnerShopController ownerShopController = ensureOwnerShopController();

    String shopId = (ownerShopController.ownerShop.value?.shopId ?? '').trim();
    if (shopId.isNotEmpty) return shopId;

    await ownerShopController.refreshShop();
    shopId = (ownerShopController.ownerShop.value?.shopId ?? '').trim();
    return shopId;
  }

  void _finalizeCreatedEvent({
    required CreateEventResponseModel event,
    required String successMessage,
    bool clearFormAfterSuccess = false,
    bool closeScreenAfterSuccess = false,
  }) {
    createdEvent.value = event;
    _applyApiResponse(event);

    if (clearFormAfterSuccess) {
      _clearForm();
    }

    if (Get.isRegistered<HomeEventController>()) {
      Get.find<HomeEventController>().fetchEvents();
    }
    if (Get.isRegistered<OwnerShopEventController>()) {
      Get.find<OwnerShopEventController>().fetchOwnerEvents();
    }

    final String message = successMessage.isNotEmpty
        ? successMessage
        : 'Event created successfully';

    if (closeScreenAfterSuccess && (Get.key.currentState?.canPop() ?? false)) {
      Get.back();
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        Get.snackbar(
          'Success',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      });
      return;
    }

    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryGreen,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    timeController.clear();
    entryFeeController.clear();
    selectedDate.value = null;
    selectedTime.value = null;
    selectedImagePath.value = null;
    responseImageUrl.value = '';
    createdEvent.value = null;
  }

  void _applyApiResponse(CreateEventResponseModel response) {
    titleController.text = response.title;
    descriptionController.text = response.description;

    final DateTime? parsedDate = DateTime.tryParse(response.date);
    if (parsedDate != null) {
      selectedDate.value = parsedDate;
      dateController.text = DateFormat('MM/dd/yyyy').format(parsedDate);
    }

    final TimeOfDay? parsedTime = _parseTime(response.time);
    if (parsedTime != null) {
      selectedTime.value = parsedTime;
      timeController.text = _formatTimeDisplay(parsedTime);
    } else {
      timeController.text = response.time;
    }

    final bool isWhole = response.entryFee % 1 == 0;
    entryFeeController.text = isWhole
        ? response.entryFee.toStringAsFixed(0)
        : response.entryFee.toStringAsFixed(2);

    responseImageUrl.value = response.image.url;
    selectedImagePath.value = null;
  }

  TimeOfDay? _parseTime(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return null;

    DateTime? parsed;
    try {
      parsed = DateFormat('HH:mm').parseStrict(value);
    } catch (_) {
      try {
        parsed = DateFormat('h:mm a').parseStrict(value);
      } catch (_) {
        parsed = null;
      }
    }

    if (parsed == null) return null;
    return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
  }

  String _formatTimeDisplay(TimeOfDay time) {
    final DateTime raw = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat('h:mm a').format(raw);
  }

  String _formatTimeApi(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    entryFeeController.dispose();
    super.onClose();
  }
}
