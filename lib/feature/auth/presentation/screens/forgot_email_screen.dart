import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';
import 'Otp_verify_screen.dart';

class EmailVerifyScreen extends StatefulWidget {
  const EmailVerifyScreen({super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
  final TextEditingController _emailController = TextEditingController();

  late final AuthFlowController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    final email = _emailController.text.trim();
    _flowController.submitForgotPasswordEmail(email);
    if (email.isNotEmpty) {
      Get.to(() => OtpVerificationScreen(email: email));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          const SizedBox(height: 54),
          Image.asset(
            AppImages.appLogo,
            width: 100,
            height: 145,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 18),
          const Text(
            'Reset password',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your email to receive the OTP',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 34),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Your Email',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Enter your Email',
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: AppColors.textFieldLightGrey,
                size: 31,
              ),
            ),
          ),
          const SizedBox(height: 34),
          PrimaryButton(
            onPressed: _continue,
            child: const Text(
              'Send OTP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
