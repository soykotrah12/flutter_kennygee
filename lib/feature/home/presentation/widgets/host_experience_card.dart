import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../create_event/presentation/screens/create_event_screen.dart';

class HostExperienceCard extends StatelessWidget {
  const HostExperienceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen,
            ),
            child: const Icon(
              Icons.celebration_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Host an Experience',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Reach more guests and grow your community with live music nights, chef\'s tables, or seasonal tastings.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 204,
            child: TextButton(
              onPressed: () => Get.to(() => const CreateEventScreen()),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                'Create Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
