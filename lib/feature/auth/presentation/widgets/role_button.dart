import 'package:flutter/material.dart';

import '../../../../core/common/constants/app_colors.dart';

class RoleButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool isUser; // true → user button, false → company button
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.isUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // set size depending on role
    final double width = isUser ? 84 : 128;
    const double height = 40;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isSelected ? TColors.userButton : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? TColors.userBorder : TColors.userButton,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TColors.userButton.withValues(alpha: 0.3),
                    blurRadius: 6,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? TColors.userName : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
