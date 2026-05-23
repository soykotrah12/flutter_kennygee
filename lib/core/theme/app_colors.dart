import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF0D4E3C);
  static const Color primaryGreen = Color(0xFF0F3D2E);
  static const Color primaryOrange = Color(0xFFF27C10);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // App Neutrals
  static const Color appBackground = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF1F1F1F);
  static const Color textGrey = Color(0xFF7D7D7D);
  static const Color subTextGrey = Color(0xFF707070);
  static const Color inputBackground = Color(0xFFE7E7E7);
  static const Color inputBorder = Color(0xFFBCBCBC);

  // Text Field Related
  static const Color textFieldLightGrey = Color(0xFF9E9E9E);
  static const Color textFieldLightLavender = Color(0xFFE1E8F6);
  static const Color logoutRed = Color(0xFFF23624);

  // Legacy colors for compatibility
  static const Color white = Color(0xFFFFFFFF);
  static const Color white1 = Color(0xFFF4F4F4);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFFB0BEC5);
  static const Color grey1 = Color(0xFF666666);
  static const Color grey2 = Color(0xFF8F8F8F);
  static const Color deliveryDetails = Color(0xFF18191A);
  static const Color account = Color(0xFFFCFDFF);
  static const Color activityColor = Color(0xFF000000);
  static const Color personalBackground = Color(0xFFDCE4F5);
  static const Color uploadImage = Color(0xFF2C2929);
  static const Color driverNavigation = Color(0xFFB2CAFF);
  static const Color enableButton = Color(0xFF0D4E3C);
  static const Color borderColor = Color(0xFFE9EEF9);
  static const Color borderColor1 = Color(0xFFE1E8F6);
  static const Color textfieldPrefixIconBackground = Color(0xFFEE5EDFF);
  static const Color redLogout = Color(0xFFFAF5F6);
  static const Color red = Color(0xFFF23624);
  static const Color borderButton = Color(0xFFDCE4F5);
  static const Color userButton = Color(0xFF0D4E3C);
  static const Color userName = Color(0xFF303133);
  static const Color userBorder = Color(0xFFF3F5FC);
  static const Color subtitleName = Color(0xFF555659);
  static const Color titleColor = Color(0xFF000000);
  static const Color subtitleColor = Color(0xFF847C7C);
  static const Color profileappbar = Color(0xFFF2F6FF);
  static const Color buttonColor = Color(0xFF0D4E3C);
  static const Color authBackground = Color(0xFFE7E7E7);
  static const Color authPurple = Color(0xFF0D4E3C);
  static const Color authInputBg = Color(0xFFE7E7E7);
  static const Color authHintText = Color(0xFF707070);
  static const Color authSecondaryText = Color(0xFF666666);
  static const Color authBorder = Color(0xFFBCBCBC);
  static const Color containerGrey = Color(0xFFF5F5F5);

  // Dark mode palette
  static const Color darkBackground = Color(0xFF011B14);
  static const Color darkCard = Color(0xFF0A3A2D);
  static const Color darkCardSoft = Color(0xFF0E4837);
  static const Color darkNav = Color(0xFF04130E);
  static const Color darkDivider = Color(0xFF1A5847);
  static const Color darkInput = Color(0xFF123D31);
  static const Color darkTextPrimary = Color(0xFFF3F6F4);
  static const Color darkTextSecondary = Color(0xFFA8B5AF);

  static bool get isDarkMode => Get.isDarkMode;

  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkBackground
      : appBackground;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : primaryWhite;

  static Color softCardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardSoft : white1;

  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextPrimary
      : textBlack;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkTextSecondary
      : textGrey;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkDivider
      : inputBorder;

  static Color inputFill(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkInput
      : inputBackground;

  static Color mutedInput(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkInput
      : const Color(0xFFE8E8E8);

  static Color badgeSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkCardSoft
      : const Color(0xFFF2ECE5);

  static Color iconCircleSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? darkInput
      : const Color(0xFFDCE5E2);

  static Color shadow(
    BuildContext context, {
    double light = 0.08,
    double dark = 0.24,
  }) => Colors.black.withValues(
    alpha: Theme.of(context).brightness == Brightness.dark ? dark : light,
  );

  static Color get backgroundAdaptive =>
      isDarkMode ? darkBackground : appBackground;
  static Color get cardAdaptive => isDarkMode ? darkCard : primaryWhite;
  static Color get softCardAdaptive => isDarkMode ? darkCardSoft : white1;
  static Color get primaryTextAdaptive =>
      isDarkMode ? darkTextPrimary : textBlack;
  static Color get secondaryTextAdaptive =>
      isDarkMode ? darkTextSecondary : textGrey;
  static Color get dividerAdaptive => isDarkMode ? darkDivider : inputBorder;
  static Color get navAdaptive => isDarkMode ? darkNav : appBackground;
}
