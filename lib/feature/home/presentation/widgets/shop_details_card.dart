import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ShopDetailsCard extends StatelessWidget {
  const ShopDetailsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onEditTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softCardColor(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop Details',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$title • $subtitle',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEditTap,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              'Edit',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
