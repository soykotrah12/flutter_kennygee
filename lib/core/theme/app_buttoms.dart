import 'package:flutter/material.dart';

import 'app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool isGradient;
  final bool isBorder;
  final Color backgroundColor;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.isLoading = false,
    this.isGradient = true,
    this.isBorder = false,
    this.backgroundColor = AppColors.primaryWhite,
    this.borderRadius = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isGradient? const LinearGradient(
                colors: [
                  Color(0xFF23AF56),
                  Color(0xFF5048E7),
                  Color(0xFF23AF56),
                ],
              ) : null,
              color: isGradient ? null : backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isBorder ? Border.all(color: AppColors.textFieldLightLavender) : null,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final double borderRadius;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.backgroundColor = AppColors.primaryWhite,
    this.textColor = AppColors.textBlack,
    this.borderColor = AppColors.textGreen,
    this.width,
    this.height,
    this.isLoading = false,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Opacity(
          opacity: isLoading ? 0.6 : 1.0,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
