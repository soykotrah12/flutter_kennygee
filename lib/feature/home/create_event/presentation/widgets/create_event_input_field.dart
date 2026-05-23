import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class CreateEventInputField extends StatelessWidget {
  const CreateEventInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '',
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.suffixIcon,
    this.prefixText,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final int maxLines;
  final Widget? suffixIcon;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.softCardColor(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            hintStyle: TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD8D8D8), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
