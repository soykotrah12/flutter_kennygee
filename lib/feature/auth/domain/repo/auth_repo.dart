import '../../../../../core/network/network_result.dart';
import '../../data/model/auth_response_model.dart';
import '../../data/model/forgot_pass_request_model.dart';
import '../../data/model/login_request_model.dart';
import '../../data/model/refresh_token_request_model.dart';
import '../../data/model/refresh_token_response_model.dart';
import '../../data/model/register_request_model.dart';
import '../../data/model/set_password_request_model.dart';
import '../../data/model/verify_otp_request-model.dart';

abstract class AuthRepository {
  NetworkResult<AuthResponseModel> login(LoginRequestModel request);
  NetworkResult<AuthResponseModel> register(RegisterRequestModel request);
  NetworkResult<void> forgotPassword(ForgotPassRequestModel request);
  NetworkResult<void> resendOtp({required String email});
  NetworkResult<AuthResponseModel?> verifyOtp(VerifyMailOtpRequest request);
  NetworkResult<void> setNewPassword(ResetPasswordRequestModel request);
  NetworkResult<void> logout();
  NetworkResult<RefreshTokenResponseModel> refreshToken(
    RefreshTokenRequestModel request,
  );
}
