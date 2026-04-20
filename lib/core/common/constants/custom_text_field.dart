import 'package:flutter/material.dart';

import 'app_colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.obscureText = false,
    this.helperText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final bool obscureText;
  final String? helperText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
        labelStyle: const TextStyle(
          color: TColors.grey2,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: prefixIcon,
        helperText: helperText,
        helperStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: TColors.grey2,
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
      ),
    );
  }
}
