import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/constants/api_constants.dart';
import '../../../../../core/network/network_result.dart';
import '../../domain/repo/auth_repo.dart';
import '../model/auth_response_model.dart';
import '../model/forgot_pass_request_model.dart';
import '../model/login_request_model.dart';
import '../model/refresh_token_request_model.dart';
import '../model/refresh_token_response_model.dart';
import '../model/register_request_model.dart';
import '../model/register_response_model.dart';
import '../model/set_password_request_model.dart';
import '../model/verify_otp_request-model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  NetworkResult<AuthResponseModel> login(LoginRequestModel request) {
    return _apiClient.post<AuthResponseModel>(
      ApiConstants.auth.login,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponseModel.fromJson(json),
      // isFormData: true
    );
  }

  @override
  NetworkResult<RegisterResponseModel> register(RegisterRequestModel request) {
    return _apiClient.post<RegisterResponseModel>(
      ApiConstants.auth.register,
      data: request.toJson(),
      fromJsonT: (json) => RegisterResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<void> forgotPassword(ForgotPassRequestModel request) {
    return _apiClient.post(
      ApiConstants.auth.forgotPass,
      data: request.toJson(),
      fromJsonT: (_) => null,
    );
  }

  @override
  NetworkResult<void> verifyOtp(VerifyMailOtpRequest request) {
    return _apiClient.post(
      ApiConstants.auth.verifyMailOtp,
      data: request.toJson(),
      fromJsonT: (_) => null,
    );
  }

  @override
  NetworkResult<void> setNewPassword(ResetPasswordRequestModel request) {
    return _apiClient.post(
      ApiConstants.auth.setNewPass,
      data: request.toJson(),
      fromJsonT: (_) => null,
    );
  }

  @override
  NetworkResult<RefreshTokenResponseModel> refreshToken(
    RefreshTokenRequestModel request,
  ) {
    return _apiClient.post(
      ApiConstants.auth.refreshToken,
      data: request.toJson(),
      fromJsonT: (json) => RefreshTokenResponseModel.fromJson(json),
    );
  }
}
