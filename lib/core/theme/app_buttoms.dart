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
  final EdgeInsetsGeometry? padding;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.isLoading = false,
    this.isGradient = false,
    this.isBorder = false,
    this.backgroundColor = AppColors.primaryGreen,
    this.borderRadius = 40,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: AnimatedOpacity(
          opacity: isLoading ? 0.65 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 64,
            padding: padding,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: isGradient
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryOrange,
                        AppColors.primaryGreen,
                      ],
                    )
                  : null,
              color: isGradient ? null : backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: isBorder
                  ? Border.all(color: AppColors.primaryGreen, width: 1.4)
                  : null,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    this.textColor = AppColors.primaryGreen,
    this.borderColor = AppColors.primaryGreen,
    this.width,
    this.height,
    this.isLoading = false,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AbsorbPointer(
        absorbing: isLoading,
        child: AnimatedOpacity(
          opacity: isLoading ? 0.65 : 1,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 60,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
