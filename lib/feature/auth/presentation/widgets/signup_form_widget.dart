import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/signup_text_field.dart';
import '../../../../core/common/constants/texts.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../controller/auth_controller.dart';

class SignupForm extends StatefulWidget {
  final String role;
  final VoidCallback onSignup;
  final VoidCallback onSignin;

  const SignupForm({
    super.key,
    required this.onSignup,
    required this.onSignin,
    required this.role,
  });

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthController authController = Get.find<AuthController>();

  bool rememberMe = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseEnterName.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseEnterEmail.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseEnterPassword.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.pleaseConfirmPassword.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.passwordsDoNotMatch.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!rememberMe) {
      Get.snackbar(
        appTexts.error.tr,
        appTexts.agreeToTerms.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Get country code from the selected country
    // Call the register method with all required parameters
    authController.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
      widget.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Text(
                appTexts.name.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.titleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// NAME
          SignUpTextField(
            controller: nameController,

            // label: "",
            hintText: "Spark Delivery",
            keyboardType: TextInputType.name,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
               Text(
                appTexts.email.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.titleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          const SizedBox(height: 8),

          SignUpTextField(
            controller: emailController,

            // label: "",
            hintText: "example@gmail.com",
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 24),

          // Country code field
          Row(
            children: [
               Text(
                appTexts.countryCode.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.titleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
               Text(
                appTexts.password.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: TColors.titleColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
              const Text(
                " *",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          const SizedBox(height: 8),

          SignUpTextField(
            controller: passwordController,

            hintText: "••••••••",
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),

          const SizedBox(height: 16),

          Text(
            appTexts.confirmPassword.tr,
            style: const TextStyle(
              fontSize: 14,
              color: TColors.titleColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          SignUpTextField(
            controller: confirmPasswordController,

            hintText: "••••••••",
            keyboardType: TextInputType.visiblePassword,
            obscureText: true,
          ),

          const SizedBox(height: 16),

          /// REMEMBER ME
          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (val) {
                  setState(() {
                    rememberMe = val ?? false;
                  });
                },
                // fillColor: MaterialStateProperty.all(TColors.subtitleColor),
                checkColor: TColors.subtitleColor, // check mark color
              ),
               Text(
                appTexts.rememberMe.tr,
                style: const TextStyle(
                  fontSize: 12,
                  color: TColors.subtitleColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 12,
                color: TColors.titleColor,
                fontWeight: FontWeight.w400,
              ),
              children: [
                 TextSpan(
                  text: appTexts.fillRequiredFields.tr,
                ),
                const TextSpan(
                  text: "*",
                  style: TextStyle(
                    color: Colors.red, // only the asterisk is red
                  ),
                ),
                 TextSpan(text: appTexts.fieldsAccurately.tr),
              ],
            ),
          ),
          const SizedBox(height: 32),

          /// SIGN UP BUTTON
          PrimaryButton(
            width: double.infinity,
            height: 51,
            backgroundColor: TColors.primary,
            borderRadius: 8.0,
            onPressed: () {
              _submit();
            }, child: Text("Submit"),
          ),

          const SizedBox(height: 32),

          /// ALREADY HAVE ACCOUNT
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(appTexts.alreadyHaveAccount.tr),
              GestureDetector(
                onTap: widget.onSignin,
                child:  Text(
                  appTexts.signIn.tr,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
