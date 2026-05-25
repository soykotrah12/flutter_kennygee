import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class CreateEventFeeSummaryCard extends StatelessWidget {
  const CreateEventFeeSummaryCard({
    super.key,
    required this.platformServiceFee,
    required this.total,
    this.onCompletePayment,
  });

  final double platformServiceFee;
  final double total;
  final VoidCallback? onCompletePayment;

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Summary',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Platform Service Fee',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              Text(
                '\$${_formatMoney(platformServiceFee)}',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                size: 12,
                color: AppColors.secondaryText(context),
              ),
              SizedBox(width: 4),
              Text(
                'Payment Method',
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: AppColors.softCardColor(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Stripe',
              style: TextStyle(
                color: Color(0xFF4149FF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              thickness: 1,
              color: AppColors.divider(context),
            ),
          ),
          Row(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              const Spacer(),
              Text(
                '\$${_formatMoney(total)}',
                style: TextStyle(
                  color: AppColors.primaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          // InkWell(
          //   onTap: onCompletePayment,
          //   borderRadius: BorderRadius.circular(6),
          //   child: Container(
          //     width: double.infinity,
          //     height: 34,
          //     alignment: Alignment.center,
          //     decoration: BoxDecoration(
          //       color: AppColors.primaryGreen,
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: Text(
          //       'Complete Payment',
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 12,
          //         fontWeight: FontWeight.w600,
          //         fontFamily: 'Montserrat',
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
