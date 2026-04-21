import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  final String email;
  final String otp;

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AuthFlowController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    _flowController.resetPassword(
      otp: widget.otp,
      password: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
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
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Reset New password',
                          style: TextStyle(
                            color: AppColors.textBlack,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your new password and confirm password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.subTextGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 34),
                      const _Label('New Password'),
                      const SizedBox(height: 12),
                      _PasswordInput(
                        controller: _passwordController,
                        hintText: 'Enter your Password',
                        obscureText: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      const _Label('Confirm Password'),
                      const SizedBox(height: 12),
                      _PasswordInput(
                        controller: _confirmController,
                        hintText: 'Enter Confirm Password',
                        obscureText: _obscureConfirm,
                        onToggle: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        height: 51,
                        onPressed: _submit,
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.onToggle,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.textFieldLightGrey,
          size: 31,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            size: 22,
            obscureText ? Icons.visibility_off_outlined : Icons.visibility,
            color: AppColors.textFieldLightGrey,
          ),
        ),
      ),
    );
  }
}
