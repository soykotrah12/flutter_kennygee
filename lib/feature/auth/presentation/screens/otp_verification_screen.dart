import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/debug_print.dart';
import '../controller/auth_flow_controller.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.purpose,
    this.role,
  });

  final String email;
  final OtpVerificationPurpose purpose;
  final AppUserRole? role;

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  late final AuthFlowController _flowController;
  Timer? _cooldownTimer;
  int _resendCooldown = 0;
  bool _isResending = false;
  bool _hasAutoResentOtp = false;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
    DPrint.log(
      'OTP SCREEN OPENED => email: ${widget.email}, purpose: ${widget.purpose.logValue}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoResendOtpIfNeeded();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verify() {
    final otp = _controllers.map((e) => e.text).join();
    if (otp.length != 6) {
      Get.snackbar(
        'Invalid OTP',
        'Please enter the complete 6 digit OTP.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _flowController.verifyEmailOtp(
      email: widget.email,
      otp: otp,
      purpose: widget.purpose,
      role: widget.role,
    );
  }

  Future<void> _resendOtp() async {
    if (_isResending || _resendCooldown > 0) return;

    await _sendResendOtp();
  }

  Future<void> _autoResendOtpIfNeeded() async {
    if (_hasAutoResentOtp || !_shouldAutoResendOtp) return;

    _hasAutoResentOtp = true;
    debugPrint('AUTO RESEND OTP TRIGGERED => ${widget.email}');
    await _sendResendOtp();
  }

  bool get _shouldAutoResendOtp =>
      widget.purpose == OtpVerificationPurpose.unverifiedLogin ||
      widget.purpose == OtpVerificationPurpose.unverifiedSignupRetry;

  Future<void> _sendResendOtp() async {
    if (_isResending || _resendCooldown > 0) return;

    setState(() {
      _isResending = true;
    });
    final sent = await _flowController.resendEmailOtp(widget.email);
    if (!mounted) return;
    setState(() {
      _isResending = false;
    });

    if (sent) {
      _startCooldown();
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() {
      _resendCooldown = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        timer.cancel();
        setState(() {
          _resendCooldown = 0;
        });
        return;
      }
      setState(() {
        _resendCooldown--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          const SizedBox(height: 55),
          Image.asset(AppImages.appLogo, width: 92, height: 130),
          const SizedBox(height: 18),
          const Text(
            'Verify OTP',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent OTP to ${widget.email}',
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: 48,
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < _focusNodes.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      _focusNodes[index - 1].requestFocus();
                    }
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldLightGrey,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.textFieldLightGrey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => PrimaryButton(
              onPressed: _verify,
              isLoading: _flowController.isSubmitting.value,
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _isResending || _resendCooldown > 0 ? null : _resendOtp,
            child: Text(
              _resendCooldown > 0
                  ? 'Resend OTP in ${_resendCooldown}s'
                  : _isResending
                  ? 'Sending...'
                  : 'Resend OTP',
              style: TextStyle(
                color: _resendCooldown > 0
                    ? AppColors.textGrey
                    : AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
