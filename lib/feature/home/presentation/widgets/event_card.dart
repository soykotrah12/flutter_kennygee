import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerEventCard extends StatelessWidget {
  const OwnerEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              const AdaptiveImage(
                path: AppImages.homeRestaurant2,
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2ECE5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    '\$10.00',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 46,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2ECE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.editfood,
                      width: 24,
                      height: 24,
                    ),
                  )
                ),
              ),
            ],
          ),
          Padding(
  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Image.asset(
            AppImages.date, 
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          const Text(
            'FRI, MAR 26',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),

          Image.asset(
            AppImages.clock,
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          const Text(
            '6:00PM - 8:00PM',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      const SizedBox(height: 6),

      const Text(
        'Chef\'s Special Tasting Night',
        style: TextStyle(
          color: AppColors.textBlack,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      const SizedBox(height: 8),

      Row(
        children: [
          Image.asset(
            AppImages.location, // 👈 already correct
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'The Gilded Fork, Downtown',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)
        ],
      ),
    );
  }
}
