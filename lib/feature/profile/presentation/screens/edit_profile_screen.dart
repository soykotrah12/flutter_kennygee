import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controller/auth_flow_controller.dart';
import '../controller/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flowController = ensureAuthFlowController();
    final profileController = ensureProfileController();

    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Edit Profile',
      body: Obx(() {
        final isInitialLoading =
            profileController.isProfileLoading.value &&
            profileController.profile.value == null;

        if (isInitialLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        final selectedRole = flowController.selectedRole.value;
        final profileRole = profileController.profile.value?.role ?? '';
        final isOwner =
            (selectedRole?.isOwner ?? false) ||
            roleFromStorage(profileRole).isOwner;

        if (isOwner) {
          return _OwnerEditProfileLayout(profileController: profileController);
        }

        return _DefaultEditProfileLayout(profileController: profileController);
      }),
    );
  }
}

class _OwnerEditProfileLayout extends StatelessWidget {
  const _OwnerEditProfileLayout({required this.profileController});

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    final profile = profileController.profile.value;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                  ),
                  child: ClipOval(
                    child: _ProfileImage(profileController: profileController),
                  ),
                ),
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: GestureDetector(
                    onTap: profileController.pickProfileImage,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F6FE8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppImages.gellary,
                          width: 23,
                          height: 23,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const _OwnerFieldLabel(text: 'User Name'),
          const SizedBox(height: 12),
          _OwnerInputField(
            child: TextField(
              controller: profileController.nameController,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                filled: false,
                fillColor: Colors.transparent,
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
          const SizedBox(height: 22),
          const _OwnerFieldLabel(text: 'Email'),
          const SizedBox(height: 12),
          _OwnerInputField(
            child: TextFormField(
              key: ValueKey('owner_email_${profile?.email ?? ''}'),
              initialValue: profile?.email ?? '',
              readOnly: true,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
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
          const SizedBox(height: 22),
          const _OwnerFieldLabel(text: 'Phone Number'),
          const SizedBox(height: 12),
          _OwnerInputField(
            child: TextFormField(
              key: ValueKey('owner_phone_${profile?.phoneNumber ?? ''}'),
              initialValue: profile?.phoneNumber ?? '',
              readOnly: true,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
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
          const SizedBox(height: 24),
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
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DefaultEditProfileLayout extends StatelessWidget {
  const _DefaultEditProfileLayout({required this.profileController});

  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
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
                  border: Border.all(color: AppColors.primaryGreen, width: 2),
                ),
                child: ClipOval(
                  child: _ProfileImage(profileController: profileController),
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
            border: Border.all(color: AppColors.divider(context), width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                'Name: ',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              Expanded(
                child: TextField(
                  controller: profileController.nameController,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: AppColors.secondaryText(context),
                    ),
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
                : Text(
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
  }
}

class _OwnerFieldLabel extends StatelessWidget {
  const _OwnerFieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.primaryText(context),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Montserrat',
      ),
    );
  }
}

class _OwnerInputField extends StatelessWidget {
  const _OwnerInputField({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider(context), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
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
