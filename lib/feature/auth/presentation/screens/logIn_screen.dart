import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';
import 'create_account_screen.dart';
import 'forgot_email_screen.dart';
import 'role_selection_screen.dart';

class LoginRoleScreen extends StatefulWidget {
  const LoginRoleScreen({super.key});

  @override
  State<LoginRoleScreen> createState() => _LoginRoleScreenState();
}

class _LoginRoleScreenState extends State<LoginRoleScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AuthFlowController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.appLogo,
                          width: 60,
                          height: 95,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _InputLabel('User Email'),
                      const SizedBox(height: 12),
                      _AuthInput(
                        controller: _emailController,
                        hintText: 'Enter your Email',
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      const _InputLabel('Password'),
                      const SizedBox(height: 12),
                      _AuthInput(
                        controller: _passwordController,
                        hintText: 'Enter your Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textFieldLightGrey,
                          ),
                          iconSize: 20,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const EmailVerifyScreen()),
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Obx(
                        () => PrimaryButton(
                          height: 51,
                          isLoading: _flowController.isSubmitting.value,
                          onPressed: () => _flowController.signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don’t have an account? ',
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final role = _flowController.selectedRole.value;
                              if (role == null) {
                                Get.to(() => const RoleSelectionScreen());
                                return;
                              }
                              Get.to(
                                () => CreateAccountScreen(selectedRole: role),
                              );
                            },
                            child: const Text(
                              'Sign Up Here',
                              style: TextStyle(
                                color: AppColors.primaryGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
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

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.textFieldLightGrey,
          size: 20,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
