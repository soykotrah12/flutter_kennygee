import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/texts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'beardfriend';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColors.authBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Title
              Text(
                appTexts.tellUsAboutYourself.tr,
                style:  TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: TColors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                appTexts.chooseToContinue.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: TColors.authSecondaryText,
                ),
              ),

              const SizedBox(height: 80),

              // Beardfriend Card
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'beardfriend';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'beardfriend'
                        ? TColors.authPurple
                        : TColors.authInputBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        color: TColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appTexts.beardfriend.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appTexts.beardfriendDesc.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: TColors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Barbershop Card
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = 'barbershop';
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedRole == 'barbershop'
                        ? TColors.authPurple
                        : TColors.authInputBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.store_outlined,
                        color: TColors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appTexts.barbershop.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: TColors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appTexts.barbershopDesc.tr,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: TColors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
