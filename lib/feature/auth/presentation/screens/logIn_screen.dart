import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/constants/texts.dart';
import '../controller/auth_controller.dart';
import 'forgot_email_screen.dart';
import 'role_selection_screen.dart';

class LoginRoleScreen extends StatefulWidget {
  const LoginRoleScreen({super.key});

  @override
  State<LoginRoleScreen> createState() => _LoginRoleScreenState();
}

class _LoginRoleScreenState extends State<LoginRoleScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseEnterEmail.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseEnterPassword.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Call API through AuthController
    _authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // App Logo (Beard Icon)
              Image.asset(
                AppImages.appLogo,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // Welcome Back Title
              Text(
                appTexts.welcomeBack.tr,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
               Text(
                appTexts.pleaseLogin.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(height: 40),

              // Email Field
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: appTexts.emailAddress.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D2D2D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: appTexts.password.tr,
                    hintStyle: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF999999),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const EmailVerifyScreen());
                  },
                  child: Text(
                    appTexts.forgotPassword.tr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Login Button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _authController.isLoading.value
                        ? null
                        : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB24BF3),
                      disabledBackgroundColor: const Color(0xFF555555),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _authController.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            appTexts.login.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Or Continue With
               Text(
                appTexts.orContinueWith.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),

              // Social Media Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // _buildSocialIcon(
                  //   'assets/images/insta.png',
                  //   onTap: () {
                  //     // Instagram login
                  //   },
                  // ),
                  // const SizedBox(width: 24),
                  // _buildSocialIcon(
                  //   'assets/images/facebook.png',
                  //   onTap: () {
                  //     // Facebook login
                  //   },
                  // ),
                  // const SizedBox(width: 24),
                  _buildSocialIcon(
                    'assets/images/google.png',
                    onTap: () {
                      // Google login
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    appTexts.dontHaveAccount.tr,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        () => const RoleSelectionScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                    child: Text(
                      appTexts.createOne.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB24BF3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  //social icon builder widget
 Widget _buildSocialIcon(String assetPath, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            assetPath,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
