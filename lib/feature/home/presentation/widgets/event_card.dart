import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/event_model.dart';

class OwnerEventCard extends StatelessWidget {
  const OwnerEventCard({
    required this.event,
    this.isLoading = false,
    this.errorMessage = '',
    this.onRetry,
    super.key,
  });

  final EventModel? event;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading && event == null) {
      return Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    if (event == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              errorMessage.isNotEmpty ? errorMessage : 'No events found',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            // if (onRetry != null) ...[
            //   const SizedBox(height: 8),
            //   TextButton(onPressed: onRetry, child: Text('Retry')),
            // ],
          ],
        ),
      );
    }

    final EventModel activeEvent = event!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
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
              AdaptiveImage(
                path: activeEvent.image,
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
                    color: AppColors.badgeSurface(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    activeEvent.fee,
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
                    color: AppColors.badgeSurface(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.editfood,
                      width: 24,
                      height: 24,
                    ),
                  ),
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
                    Image.asset(AppImages.date, width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(
                      activeEvent.date,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(AppImages.clock, width: 14, height: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activeEvent.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  activeEvent.title,
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Image.asset(AppImages.location, width: 14, height: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activeEvent.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
