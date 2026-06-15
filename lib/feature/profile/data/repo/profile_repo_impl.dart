import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../../domain/repo/profile_repo.dart';
import '../model/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  NetworkResult<UserProfileModel> getProfile({CancelToken? cancelToken}) {
    return _apiClient.get<UserProfileModel>(
      ApiConstants.user.getUserProfile,
      cancelToken: cancelToken,
      fromJsonT: (json) => UserProfileModel.fromJson(_asMap(json)),
    );
  }

  @override
  NetworkResult<UserProfileModel> updateProfile({
    required String name,
    String? phoneNumber,
    String? profileImagePath,
  }) {
    final payload = <String, dynamic>{'name': name.trim()};

    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      payload['phoneNumber'] = phoneNumber.trim();
    }

    if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
      payload['profileImage'] = MultipartFile.fromFileSync(
        profileImagePath,
        filename: profileImagePath.split('/').last,
      );
    }

    final formData = FormData.fromMap(payload);

    return _apiClient.put<UserProfileModel>(
      ApiConstants.user.updateProfile,
      formData: formData,
      isFormData: true,
      options: Options(contentType: 'multipart/form-data'),
      fromJsonT: (json) => UserProfileModel.fromJson(_asMap(json)),
    );
  }

  @override
  NetworkResult<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final payload = {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmNewPassword,
    };

    final result = await _apiClient.put<void>(
      ApiConstants.user.changePassword,
      data: payload,
      fromJsonT: (_) {},
    );

    if (result.isRight()) {
      return result;
    }

    return result.fold((failure) async {
      // Fallback for backends exposing this route under /auth.
      if (failure.statusCode == 404 || failure.statusCode == 405) {
        return _apiClient.put<void>(
          ApiConstants.auth.changePass,
          data: payload,
          fromJsonT: (_) {},
        );
      }
      return Left(failure);
    }, (success) async => Right(success));
  }

  @override
  NetworkResult<void> deleteAccount({required String password}) {
    final payload = {'password': password};

    return _apiClient.delete<void>(
      ApiConstants.user.deleteAccount,
      data: payload,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: ApiConstants.defaultHeaders,
      ),
      fromJsonT: (_) {},
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
