import 'package:dio/dio.dart';

import '../../../../../core/network/network_result.dart';
import '../../data/model/user_profile_model.dart';

abstract class ProfileRepository {
  NetworkResult<UserProfileModel> getProfile({CancelToken? cancelToken});

  NetworkResult<UserProfileModel> updateProfile({
    required String name,
    String? phoneNumber,
    String? profileImagePath,
  });

  NetworkResult<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  NetworkResult<void> deleteAccount({required String password});
}
