import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme({
    required Color primaryText,
    required Color secondaryText,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 57,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 45,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 36,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 42,
        height: 1.12,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 34,
        height: 1.15,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w700,
        fontSize: 30,
        height: 1.2,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.2,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.25,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 18,
        height: 1.3,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 1.35,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Montserrat',
        color: secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.2,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.25,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Montserrat',
        color: primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
      ),
    );
  }

  static ThemeData get light {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: AppColors.inputBorder, width: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.appBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryOrange,
        surface: AppColors.appBackground,
      ),
      fontFamily: 'Montserrat',
      textTheme: _buildTextTheme(
        primaryText: AppColors.textBlack,
        secondaryText: AppColors.textGrey,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
        errorBorder: inputBorder,
        focusedErrorBorder: inputBorder,
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.subTextGrey,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.textBlack,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textBlack,
      ),
    );
  }

  static ThemeData get dark {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: AppColors.darkDivider, width: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        secondary: AppColors.primaryOrange,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
      ),
      cardColor: AppColors.darkCard,
      dividerColor: AppColors.darkDivider,
      fontFamily: 'Montserrat',
      textTheme: _buildTextTheme(
        primaryText: AppColors.darkTextPrimary,
        secondaryText: AppColors.darkTextSecondary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInput,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
        errorBorder: inputBorder,
        focusedErrorBorder: inputBorder,
        hintStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        labelStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.darkTextPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryGreen;
          }
          return AppColors.darkTextPrimary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkCardSoft;
          }
          return AppColors.darkNav;
        }),
      ),
    );
  }
}
