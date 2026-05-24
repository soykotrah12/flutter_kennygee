import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OwnerMapUnsavedActionBar extends StatelessWidget {
  const OwnerMapUnsavedActionBar({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onCancel,
    required this.onUseLocation,
    required this.isResolvingAddress,
  });

  final String address;
  final double latitude;
  final double longitude;
  final VoidCallback onCancel;
  final VoidCallback onUseLocation;
  final bool isResolvingAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.08, dark: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isResolvingAddress ? 'Updating...' : 'Unsaved Location',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.trim().isEmpty ? 'Address unavailable' : address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lat ${latitude.toStringAsFixed(5)} • Lng ${longitude.toStringAsFixed(5)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.softCardColor(context),
                  foregroundColor: AppColors.primaryText(context),
                  minimumSize: const Size(70, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onUseLocation,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(88, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Use Location',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
