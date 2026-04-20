import 'package:flutter/material.dart';

import 'app_colors.dart';

extension InputDecorationExtensions on BuildContext {
  InputDecoration get primaryInputDecoration => InputDecoration(
    filled: true,
    suffixIconColor: AppColors.textFieldLightGrey,
    fillColor: AppColors.primaryWhite,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: AppColors.textFieldLightLavender),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: AppColors.textFieldLightLavender),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide(color: AppColors.textBlack, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: AppColors.logoutRed, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(color: AppColors.logoutRed, width: 1),
    ),
    hintStyle: TextStyle(
      color: AppColors.textFieldLightGrey,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    labelStyle: TextStyle(
      color: AppColors.textBlack,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    errorStyle: const TextStyle(
      color: AppColors.logoutRed,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}
//