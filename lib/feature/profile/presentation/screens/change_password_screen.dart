import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = ensureProfileController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Change Password',

      body: Obx(
        () => Column(
          children: [
            const SizedBox(height: 22),
            _PasswordField(
              hintText: 'Current Password',
              controller: profileController.currentPasswordController,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              hintText: 'New Password',
              controller: profileController.newPasswordController,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              hintText: 'Confirm New Password',
              controller: profileController.confirmNewPasswordController,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 51,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileController.isChangingPassword.value
                    ? null
                    : profileController.changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: profileController.isChangingPassword.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.hintText, required this.controller});

  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Montserrat',
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 22,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.textGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
