import 'package:flutter/material.dart';

import '../common/constants/app_colors.dart';

class AppTheme {

  static TextTheme get _textTheme {
    final base = ThemeData(fontFamily: 'Nunito').textTheme;
    TextStyle w6(TextStyle? s) => (s ?? const TextStyle()).copyWith(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          color: Colors.white,
        );
    return base.copyWith(
      displayLarge: w6(base.displayLarge),
      displayMedium: w6(base.displayMedium),
      displaySmall: w6(base.displaySmall),
      headlineLarge: w6(base.headlineLarge),
      headlineMedium: w6(base.headlineMedium),
      headlineSmall: w6(base.headlineSmall),
      titleLarge: w6(base.titleLarge),
      titleMedium: w6(base.titleMedium),
      titleSmall: w6(base.titleSmall),
      bodyLarge: w6(base.bodyLarge),
      bodyMedium: w6(base.bodyMedium),
      bodySmall: w6(base.bodySmall),
      labelLarge: w6(base.labelLarge),
      labelMedium: w6(base.labelMedium),
      labelSmall: w6(base.labelSmall),
    );
  }

  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Dark Background
    primaryColor: TColors.authPurple,
    colorScheme: ColorScheme.dark(
      primary: TColors.authPurple,
      surface: const Color(0xFF2D2D2D),
    ),
    fontFamily: 'Nunito',
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
