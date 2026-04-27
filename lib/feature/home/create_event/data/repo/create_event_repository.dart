import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/constants/api_constants.dart';
import '../../../../../core/network/network_result.dart';
import '../model/create_event_request_model.dart';
import '../model/create_event_response_model.dart';

class CreateEventRepository {
  CreateEventRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<CreateEventResponseModel> createEvent({
    required CreateEventRequestModel request,
  }) {
    final Map<String, dynamic> payload = request.toPayload();
    final String imagePath = request.imagePath?.trim() ?? '';

    if (imagePath.isNotEmpty) {
      payload['image'] = MultipartFile.fromFileSync(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }

    return _apiClient.post<CreateEventResponseModel>(
      ApiConstants.event.createEvent,
      formData: FormData.fromMap(payload),
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) => CreateEventResponseModel.fromJson(_asMap(json)),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
