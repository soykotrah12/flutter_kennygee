import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/network/constants/key_constants.dart';
import '../model/create_shop_response_model.dart';

class OwnerShopLocalStore {
  OwnerShopLocalStore({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<CreateShopResponseModel?> getShop() async {
    final String? raw = await _secureStorage.read(
      key: KeyConstants.ownerShopData,
    );
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final Map<String, dynamic> map = decoded.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      return CreateShopResponseModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveShop(CreateShopResponseModel shop) async {
    final String encoded = jsonEncode(shop.toJson());
    await _secureStorage.write(key: KeyConstants.ownerShopData, value: encoded);
  }

  Future<void> clearShop() async {
    await _secureStorage.delete(key: KeyConstants.ownerShopData);
  }
}
