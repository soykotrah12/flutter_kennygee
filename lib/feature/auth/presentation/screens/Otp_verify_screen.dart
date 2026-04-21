import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import 'set_new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, required this.email});

  final String email;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _seconds = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
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

    Get.to(() => SetNewPasswordScreen(email: widget.email, otp: otp));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          AppImages.appLogo,
                          width: 59,
                          height: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Center(
                        child: Text(
                          'Enter OTP',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, rowConstraints) {
                          const spacing = 8.0;
                          final boxWidth = ((rowConstraints.maxWidth -
                                      (spacing * 5)) /
                                  6)
                              .clamp(40.0, 78.0)
                              .toDouble();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => SizedBox(
                                width: boxWidth,
                                child: _OtpDigitBox(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  onChanged: (value) {
                                    if (value.isNotEmpty &&
                                        index < _focusNodes.length - 1) {
                                      _focusNodes[index + 1].requestFocus();
                                    } else if (value.isEmpty && index > 0) {
                                      _focusNodes[index - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          'Resend code in ${_seconds}s',
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Didn’t Receive OTP? ',
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: _seconds == 0 ? _startTimer : null,
                              child: Text(
                                'RESEND OTP',
                                style: TextStyle(
                                  color: _seconds == 0
                                      ? AppColors.primaryGreen
                                      : AppColors.primaryGreen
                                          .withValues(alpha: 0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      PrimaryButton(
                        height: 51,
                        onPressed: _verify,
                        child: const Text(
                          'Verify Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF1C2E52),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF8A8A8A), width: 1.4),
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF8A8A8A), width: 1.4),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
    );
  }
}
