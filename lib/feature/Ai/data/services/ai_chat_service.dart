import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../models/ai_chat_response_model.dart';
import '../models/chat_history_item_model.dart';

class AiChatService {
  AiChatService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<ChatHistoryItemModel>> fetchChats() {
    return _apiClient.get<List<ChatHistoryItemModel>>(
      ApiConstants.chat.chats,
      fromJsonT: (json) {
        final List<dynamic> list = json is List
            ? json
            : (_asMap(json)['data'] is List
                  ? _asMap(json)['data'] as List
                  : <dynamic>[]);

        return list
            .whereType<Map>()
            .map((item) => ChatHistoryItemModel.fromJson(_asMap(item)))
            .toList();
      },
    );
  }

  NetworkResult<AiChatResponseModel> createChat({
    required String message,
    required double lat,
    required double lng,
  }) {
    final Map<String, dynamic> body = <String, dynamic>{
      'message': message,
      'location': <String, dynamic>{'lat': lat, 'lng': lng},
    };
    debugPrint('AI CHAT POST BODY => $body');

    return _apiClient.post<AiChatResponseModel>(
      ApiConstants.chat.chats,
      data: body,
      options: Options(contentType: Headers.jsonContentType),
      fromJsonT: (json) {
        final Map<String, dynamic> responseMap = _asMap(json);
        if (responseMap.containsKey('type') &&
            responseMap.containsKey('data')) {
          return AiChatResponseModel.fromJson(responseMap);
        }
        return AiChatResponseModel.fromJson(_asMap(responseMap['data']));
      },
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return <String, dynamic>{};
}
