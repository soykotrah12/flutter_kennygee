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
    final formData = _buildFormData(request);

    return _apiClient.post<CreateShopResponseModel>(
      ApiConstants.shop.createShop,
      formData: formData,
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) => CreateShopResponseModel.fromJson(_asMap(json)),
    );
  }

  NetworkResult<CreateShopResponseModel> updateShop({
    required String shopId,
    required CreateShopRequestModel request,
  }) {
    final formData = _buildFormData(request);

    return _apiClient.put<CreateShopResponseModel>(
      ApiConstants.shop.updateShop(shopId),
      formData: formData,
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) => CreateShopResponseModel.fromJson(_asMap(json)),
    );
  }

  FormData _buildFormData(CreateShopRequestModel request) {
    final payload = request.toPayload();

    final Map<String, dynamic> map = <String, dynamic>{
      'userId': payload['userId'],
      'restaurantName': payload['restaurantName'],
      'description': payload['description'],
      'location': jsonEncode(payload['location']),
      'operatingHours': jsonEncode(payload['operatingHours']),
    };

    final String? imagePath = request.imagePath?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      map['image'] = MultipartFile.fromFileSync(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }

    return FormData.fromMap(map);
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
