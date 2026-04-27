import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../presentation/controller/home_event_controller.dart';
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

    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();
    final String entryFeeRaw = entryFeeController.text.trim();
    final DateTime? eventDate = selectedDate.value;
    final TimeOfDay? eventTime = selectedTime.value;

    if (title.isEmpty) {
      _showError('Validation', 'Event title is required.');
      return;
    }

    if (description.isEmpty) {
      _showError('Validation', 'Description is required.');
      return;
    }

    if (eventDate == null) {
      _showError('Validation', 'Please select an event date.');
      return;
    }

    if (eventTime == null) {
      _showError('Validation', 'Please select event time.');
      return;
    }

    final double? entryFee = double.tryParse(entryFeeRaw);
    if (entryFee == null || entryFee < 0) {
      _showError('Validation', 'Please enter a valid entry fee.');
      return;
    }

    final CreateEventRequestModel request = CreateEventRequestModel(
      title: title,
      description: description,
      date: eventDate,
      time: _formatTimeApi(eventTime),
      entryFee: entryFee,
      imagePath: selectedImagePath.value,
    );

    isSubmitting.value = true;
    final result = await _repository.createEvent(request: request);
    isSubmitting.value = false;

    result.fold(
      (failure) {
        _showError('Create Failed', failure.message);
      },
      (success) {
        createdEvent.value = success.data;
        _applyApiResponse(success.data);

        if (Get.isRegistered<HomeEventController>()) {
          Get.find<HomeEventController>().fetchEvents();
        }

        Get.snackbar(
          'Success',
          success.message.isNotEmpty
              ? success.message
              : 'Event created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryGreen,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      },
    );
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
      backgroundColor: Colors.white,
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
