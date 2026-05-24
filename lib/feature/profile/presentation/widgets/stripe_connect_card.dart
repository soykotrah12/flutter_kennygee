import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StripeConnectCard extends StatelessWidget {
  const StripeConnectCard({
    super.key,
    required this.isConnected,
    required this.isLoading,
    required this.onTap,
  });

  final bool isConnected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = isConnected
        ? AppColors.primaryGreen
        : AppColors.primaryOrange;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.divider(context), width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Stripe Connect',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isConnected
                        ? 'Stripe account connected'
                        : 'Connect your Stripe account to receive payments',
                    style: TextStyle(
                      color: AppColors.secondaryText(context),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isLoading)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryGreen,
                ),
              )
            else
              Text(
                isConnected ? 'Connected' : 'Connect',
                style: TextStyle(
                  color: isConnected
                      ? AppColors.primaryGreen
                      : AppColors.primaryOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
