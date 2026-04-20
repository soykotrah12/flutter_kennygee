import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomLogInTextField extends StatelessWidget {
  const CustomLogInTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.obscureText = false,
    this.helperText,
    this.validator,
    this.width,
    this.height,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? helperText;
  final String? Function(String?)? validator;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 335,
      height: height ?? 40,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: TColors.grey2, fontSize: 14),
          prefixIcon: prefixIcon, // ✅ fixed here
          helperText: helperText,
          helperStyle: const TextStyle(
            fontSize: 12,
            color: TColors.deliveryDetails,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: TColors.grey2, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: TColors.grey2, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
