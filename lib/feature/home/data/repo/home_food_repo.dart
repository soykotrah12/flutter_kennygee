import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/food_model.dart';
import '../model/menu_api_response.dart';
import '../model/nearby_food_api_model.dart';
import '../model/shop_menu_item_api_model.dart';
import '../model/update_menu_request_model.dart';
import '../model/update_menu_response_model.dart';

class HomeFoodRepository {
  HomeFoodRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<FoodModel>> fetchNearbyFoods({
    required double lat,
    required double lng,
  }) {
    return _apiClient.get<List<FoodModel>>(
      ApiConstants.menu.fetchNearbyMenus,
      queryParameters: <String, dynamic>{'lat': lat, 'lng': lng},
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => NearbyFoodApiModel.fromJson(_asMap(item)))
            .map(_toFoodModel)
            .toList();
      },
    );
  }

  NetworkResult<FoodModel> fetchMenuDetails({
    required String menuId,
    required double lat,
    required double lng,
  }) {
    return _apiClient.get<FoodModel>(
      ApiConstants.menu.fetchMenuDetails(menuId),
      queryParameters: <String, dynamic>{'lat': lat, 'lng': lng},
      fromJsonT: (json) {
        final NearbyFoodApiModel raw = NearbyFoodApiModel.fromJson(
          _asMap(json),
        );
        return _toFoodModel(raw);
      },
    );
  }

  NetworkResult<List<FoodModel>> fetchShopMenus({required String shopId}) {
    return _apiClient.get<List<FoodModel>>(
      ApiConstants.menu.fetchShopMenus(shopId),
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];
        return raw
            .map((item) => ShopMenuItemApiModel.fromJson(_asMap(item)))
            .map(_toShopFoodModel)
            .toList();
      },
    );
  }

  NetworkResult<UpdateMenuResponseModel> updateMenu({
    required String menuId,
    required UpdateMenuRequestModel request,
  }) {
    final formData = _buildMenuFormData(request);

    return _apiClient.put<UpdateMenuResponseModel>(
      ApiConstants.menu.updateMenu(menuId),
      formData: formData,
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) {
        final Map<String, dynamic> dataJson = json is Map<String, dynamic>
            ? json
            : <String, dynamic>{};
        return UpdateMenuResponseModel.fromJson(dataJson);
      },
    );
  }

  NetworkResult<MenuApiResponse<void>> deleteMenu({
    required String menuId,
  }) {
    return _apiClient.delete<MenuApiResponse<void>>(
      ApiConstants.menu.deleteMenu(menuId),
      fromJsonT: (json) {
        return MenuApiResponse<void>.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        );
      },
    );
  }

  NetworkResult<MenuApiResponse<void>> toggleSpecialOffer({
    required String menuId,
  }) {
    return _apiClient.put<MenuApiResponse<void>>(
      ApiConstants.menu.toggleSpecialOffer(menuId),
      data: <String, dynamic>{},
      fromJsonT: (json) {
        return MenuApiResponse<void>.fromJson(
          json is Map<String, dynamic> ? json : <String, dynamic>{},
        );
      },
    );
  }

  FormData _buildMenuFormData(UpdateMenuRequestModel request) {
    final Map<String, dynamic> map = <String, dynamic>{
      'dishName': request.dishName,
      'description': request.description,
      'category': request.category,
      'basePrice': request.priceString,
      'specialOffer': request.specialOffer.toString(),
      'offerText': request.offerText,
    };

    final String? imagePath = request.imagePath?.trim();
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          map['images'] = MultipartFile.fromFileSync(
            imagePath,
            filename: imagePath.split('/').last,
          );
        }
      } catch (e) {
        // If file cannot be read, continue without the image
      }
    }

    return FormData.fromMap(map);
  }

  FoodModel _toFoodModel(NearbyFoodApiModel food) {
    return FoodModel(
      id: food.menuId,
      name: food.dishName,
      image: food.imageUrl,
      price: food.price,
      rating: food.rating,
      reviewsCount: food.reviewsCount,
      description: food.description,
      restaurantName: food.restaurantName,
      distance: food.distance.isNotEmpty ? food.distance : 'N/A',
      address: food.address,
      openingHours: food.openingHours,
      images: food.imageUrls,
      isLiked: false,
    );
  }

  FoodModel _toShopFoodModel(ShopMenuItemApiModel food) {
    final String firstImageUrl = food.images.isNotEmpty
        ? food.images.first.url
        : '';

    return FoodModel(
      id: food.menuId,
      name: food.dishName,
      image: firstImageUrl,
      price: food.price,
      rating: 0,
      reviewsCount: 0,
      description: food.description,
      restaurantName: '',
      distance: '',
      address: '',
      openingHours: '',
      images: food.images.map((image) => image.url).toList(),
      isLiked: false,
      specialOffer: food.specialOffer,
      offerText: food.offerText,
      category: food.category,
    );
  }

  UpdateMenuResponseModel toUpdateMenuResponseModel(
    ShopMenuItemApiModel food,
  ) {
    return UpdateMenuResponseModel(
      menuId: food.menuId,
      shopId: '',
      dishName: food.dishName,
      description: food.description,
      category: food.category,
      basePrice: food.price,
      specialOffer: food.specialOffer,
      offerText: food.offerText,
      images: food.images
          .map((img) => UpdateMenuImageModel(
                publicId: img.publicId,
                url: img.url,
                id: '',
              ))
          .toList(),
      createdAt: '',
      updatedAt: '',
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
