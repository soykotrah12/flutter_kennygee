import '../../../../core/network/network_result.dart';
import '../models/ai_chat_response_model.dart';
import '../models/chat_history_item_model.dart';
import '../services/ai_chat_service.dart';

class AiChatRepository {
  AiChatRepository({required AiChatService service}) : _service = service;

  final AiChatService _service;

  NetworkResult<List<ChatHistoryItemModel>> fetchChats() {
    return _service.fetchChats();
  }

  NetworkResult<AiChatResponseModel> createChat({
    required String message,
    required double lat,
    required double lng,
  }) {
    return _service.createChat(message: message, lat: lat, lng: lng);
  }
}
