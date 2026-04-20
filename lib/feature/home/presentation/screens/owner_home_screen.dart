import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.appLogo,
                width: 36,
                height: 54,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 1.2),
                  image: const DecorationImage(
                    image: AssetImage(AppImages.ownerOnboarding1),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Welcome back,\nThe Culinary Architect',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  onPressed: () {},
                  text: 'Boost Now',
                  height: 60,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  onPressed: () {},
                  height: 60,
                  borderRadius: 12,
                  child: const Text(
                    'Add Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _StatsCard(
                  icon: Icons.star,
                  iconColor: AppColors.primaryOrange,
                  title: 'Average Rating',
                  value: '4.8',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatsCard(
                  icon: Icons.reviews_outlined,
                  iconColor: Color(0xFF34B58A),
                  title: 'Total Reviews',
                  value: '1,240',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Color(0xFFFFCF57), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Active Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text(
                      'Basic Promotion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '\$129/month',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  onPressed: () {},
                  text: 'Upgrade Plan',
                  height: 52,
                  backgroundColor: AppColors.primaryWhite,
                  textColor: AppColors.primaryGreen,
                  borderColor: Colors.transparent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Text(
                'Recent Reviews',
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Text(
                'View all',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: AppColors.primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ReviewCard(image: AppImages.homeRestaurant1),
          const SizedBox(height: 14),
          const _ReviewCard(image: AppImages.homeRestaurant2),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.containerGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.textFieldLightLavender),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Image.asset(
              image,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(AppImages.ownerOnboarding1),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Rikan Bhart',
                              style: TextStyle(
                                color: AppColors.textBlack,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '7 minute ago',
                            style: TextStyle(
                              color: AppColors.subTextGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 18, color: AppColors.primaryOrange),
                          Icon(Icons.star, size: 18, color: AppColors.primaryOrange),
                          Icon(Icons.star, size: 18, color: AppColors.primaryOrange),
                          Icon(Icons.star, size: 18, color: AppColors.primaryOrange),
                          Icon(Icons.star, size: 18, color: AppColors.primaryOrange),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Great food, nice ambiance and friendly service. The dishes were fresh, flavorful and well presented.',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
