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
      isScrollable: false,
      backgroundColor: AppColors.background(context),
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
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Reset password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email to receive the OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 34),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Email',
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your Email',
                          prefixIcon: Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.secondaryText(context),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      PrimaryButton(
                        height: 51,
                        onPressed: _continue,
                        child: const Text(
                          'Send OTP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
