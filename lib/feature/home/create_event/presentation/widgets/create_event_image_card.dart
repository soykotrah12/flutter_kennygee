import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/adaptive_image.dart';
import '../../../../../core/theme/app_colors.dart';

class CreateEventImageCard extends StatelessWidget {
  const CreateEventImageCard({
    super.key,
    required this.localImagePath,
    required this.remoteImageUrl,
    required this.onTap,
  });

  final String? localImagePath;
  final String remoteImageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String localPath = localImagePath?.trim() ?? '';
    final bool hasLocal = localPath.isNotEmpty;
    final bool hasRemote = remoteImageUrl.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.softCardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: hasLocal
                    ? Image.file(File(localPath), fit: BoxFit.cover)
                    : hasRemote
                    ? AdaptiveImage(path: remoteImageUrl, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            size: 34,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload Event Photo',
                            style: TextStyle(
                              color: AppColors.primaryText(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap to choose image',
                            style: TextStyle(
                              color: AppColors.secondaryText(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
