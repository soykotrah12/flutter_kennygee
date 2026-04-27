import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/create_shop_request_model.dart';
import '../model/create_shop_response_model.dart';

class CreateShopRepository {
  CreateShopRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<CreateShopResponseModel> createShop({
    required CreateShopRequestModel request,
  }) {
    final payload = request.toPayload();

    final formData = FormData.fromMap(<String, dynamic>{
      'userId': payload['userId'],
      'restaurantName': payload['restaurantName'],
      'description': payload['description'],
      'location': jsonEncode(payload['location']),
      'operatingHours': jsonEncode(payload['operatingHours']),
      'image': MultipartFile.fromFileSync(
        request.imagePath,
        filename: request.imagePath.split('/').last,
      ),
    });

    return _apiClient.post<CreateShopResponseModel>(
      ApiConstants.shop.createShop,
      formData: formData,
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) => CreateShopResponseModel.fromJson(_asMap(json)),
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
