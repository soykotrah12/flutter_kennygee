import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/services/auth_storage_service.dart';
import '../../../profile/data/repo/profile_repo_impl.dart';
import '../../../profile/domain/repo/profile_repo.dart';
import '../../data/models/ai_chat_response_model.dart';
import '../../data/models/ai_chat_restaurant_model.dart';
import '../../data/models/chat_history_item_model.dart';
import '../../data/repositories/ai_chat_repository.dart';
import '../../data/services/ai_chat_service.dart';

class AiChatController extends GetxController {
  AiChatController(this._repository);

  final AiChatRepository _repository;

  final TextEditingController messageController = TextEditingController();
  final RxList<ChatHistoryItemModel> chats = <ChatHistoryItemModel>[].obs;
  final RxList<AiChatUiMessage> messages = <AiChatUiMessage>[].obs;
  final RxBool isLoadingChats = false.obs;
  final RxBool isSending = false.obs;
  final RxString error = ''.obs;
  final RxString userAvatarUrl = ''.obs;
  bool _hasSentLocationPrompt = false;
  bool _hasLoadedUserProfile = false;

  static const double _defaultEntryLat = 23.8403;
  static const double _defaultEntryLng = 90.4125;

  static AiChatController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<AiChatService>()) {
      Get.lazyPut<AiChatService>(
        () => AiChatService(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AiChatRepository>()) {
      Get.lazyPut<AiChatRepository>(
        () => AiChatRepository(service: Get.find<AiChatService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AiChatController>()) {
      Get.put<AiChatController>(AiChatController(Get.find<AiChatRepository>()));
    }

    return Get.find<AiChatController>();
  }

  @override
  void onInit() {
    super.onInit();
    if (_isAccountDeleting) return;
    fetchChats();
    fetchUserProfileOnce();
  }

  Future<void> fetchChats() async {
    if (isLoadingChats.value || _isAccountDeleting || isClosed) return;

    isLoadingChats.value = true;
    error.value = '';

    final result = await _repository.fetchChats();
    if (_isAccountDeleting || isClosed) return;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        error.value = _toUserFriendlyError(failure.message);
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        chats.assignAll(success.data);
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isLoadingChats.value = false;
    }
  }

  Future<void> sendMessage({
    String? message,
    double? lat,
    double? lng,
    bool addUserBubble = true,
  }) async {
    if (_isAccountDeleting || isClosed) return;

    final String content = (message ?? messageController.text).trim();
    if (content.isEmpty || isSending.value) return;
    if (message == null) {
      messageController.clear();
    }

    if (addUserBubble) {
      messages.add(AiChatUiMessage.user(content));
      messages.refresh();
    }
    isSending.value = true;
    final double effectiveLat = lat ?? _defaultEntryLat;
    final double effectiveLng = lng ?? _defaultEntryLng;
    debugPrint('AI createChat lat=$effectiveLat lng=$effectiveLng');

    final result = await _repository.createChat(
      message: content,
      lat: effectiveLat,
      lng: effectiveLng,
    );
    if (_isAccountDeleting || isClosed) return;

    result.fold(
      (failure) {
        if (_isAccountDeleting || isClosed) return;
        if (!addUserBubble) {
          isSending.value = false;
          return;
        }
        messages.add(
          AiChatUiMessage.assistant(
            _toUserFriendlyError(failure.message),
            isError: true,
          ),
        );
        messages.refresh();
      },
      (success) {
        if (_isAccountDeleting || isClosed) return;
        _appendApiResponse(success.data);
        fetchChats();
      },
    );

    if (!_isAccountDeleting && !isClosed) {
      isSending.value = false;
    }
  }

  Future<void> sendLocationPromptOnce() async {
    if (_hasSentLocationPrompt || _isAccountDeleting || isClosed) return;
    _hasSentLocationPrompt = true;
    debugPrint('AI auto location called');

    await sendMessage(
      message: 'show me near',
      lat: _defaultEntryLat,
      lng: _defaultEntryLng,
      addUserBubble: false,
    );
  }

  Future<void> fetchUserProfileOnce() async {
    if (_hasLoadedUserProfile || _isAccountDeleting || isClosed) return;
    _hasLoadedUserProfile = true;

    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<ProfileRepository>()) {
      Get.lazyPut<ProfileRepository>(
        () => ProfileRepositoryImpl(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    final ProfileRepository repository = Get.find<ProfileRepository>();
    final result = await repository.getProfile();
    if (_isAccountDeleting || isClosed) return;
    result.fold((_) {}, (success) {
      if (_isAccountDeleting || isClosed) return;
      userAvatarUrl.value = success.data.profileImage.url.trim();
    });
  }

  void _appendApiResponse(AiChatResponseModel response) {
    if (_isAccountDeleting || isClosed) return;

    final String responseType = response.type.trim();
    final String normalizedType = responseType.toLowerCase();

    if (normalizedType == 'restaurants') {
      final List<AiChatRestaurantModel> restaurants = response.listData
          .whereType<Map>()
          .map(
            (item) => AiChatRestaurantModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList();

      if (restaurants.isNotEmpty) {
        messages.add(
          AiChatUiMessage.assistant(
            null,
            responseType: responseType,
            restaurants: restaurants,
          ),
        );
        messages.refresh();
        return;
      }
    }

    final String text = response.textData;
    if (text.isNotEmpty) {
      messages.add(AiChatUiMessage.assistant(text, responseType: responseType));
      messages.refresh();
    }
  }

  String _toUserFriendlyError(String rawMessage) {
    final String message = rawMessage.trim();
    if (message.isEmpty) return 'Something went wrong. Please try again.';

    final bool looksLikeJson =
        (message.startsWith('{') && message.endsWith('}')) ||
        message.contains('"success"') ||
        message.contains('"errorSources"') ||
        message.contains('"data"');

    if (looksLikeJson) {
      return 'Something went wrong. Please try again.';
    }

    if (message.length > 180) {
      return 'Something went wrong. Please try again.';
    }

    return message;
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  bool get _isAccountDeleting =>
      AuthStorageService.isClearingAfterAccountDelete;
}

class AiChatUiMessage {
  const AiChatUiMessage({
    this.text,
    required this.isFromUser,
    this.responseType,
    this.isError = false,
    this.restaurants = const <AiChatRestaurantModel>[],
  });

  final String? text;
  final bool isFromUser;
  final String? responseType;
  final bool isError;
  final List<AiChatRestaurantModel> restaurants;

  bool get isLocationResponse => responseType?.toLowerCase() == 'location';
  bool get hasRestaurants => restaurants.isNotEmpty;
  bool get hasText => (text ?? '').trim().isNotEmpty;

  factory AiChatUiMessage.user(String text) {
    return AiChatUiMessage(text: text, isFromUser: true);
  }

  factory AiChatUiMessage.assistant(
    String? text, {
    String? responseType,
    bool isError = false,
    List<AiChatRestaurantModel> restaurants = const <AiChatRestaurantModel>[],
  }) {
    return AiChatUiMessage(
      text: text,
      isFromUser: false,
      responseType: responseType,
      isError: isError,
      restaurants: restaurants,
    );
  }
}
