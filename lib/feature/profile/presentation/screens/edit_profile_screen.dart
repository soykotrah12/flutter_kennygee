import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = ensureProfileController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Edit Profile',
      body: Obx(() {
        final isInitialLoading =
            profileController.isProfileLoading.value &&
            profileController.profile.value == null;

        if (isInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: _ProfileImage(
                        profileController: profileController,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: GestureDetector(
                      onTap: profileController.pickProfileImage,
                      child: Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F6FE8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Image.asset(
                            AppImages.gellary,
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              height: 60,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textGrey, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text(
                    'Name: ',
                    style: TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: profileController.nameController,
                      style: const TextStyle(
                        color: AppColors.textBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isCollapsed: true,
                      ),
                    
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 51,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: profileController.isSaving.value
                    ? null
                    : profileController.updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: profileController.isSaving.value
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
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({required this.profileController});

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final localImagePath = profileController.selectedImagePath.value;
      if (localImagePath != null && localImagePath.isNotEmpty) {
        return Image.file(File(localImagePath), fit: BoxFit.cover);
      }

      final remoteImageUrl = profileController.profile.value?.profileImage.url;
      if (remoteImageUrl != null && remoteImageUrl.isNotEmpty) {
        return Image.network(
          remoteImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Image.asset(AppImages.defaultProfileImage, fit: BoxFit.cover),
        );
      }

      return Image.asset(AppImages.defaultProfileImage, fit: BoxFit.cover);
    });
  }
}
