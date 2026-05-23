import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MapSearchBar extends StatelessWidget {
  const MapSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    this.showBackButton = false,
    this.onBackTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          GestureDetector(
            onTap: onBackTap,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryGreen,
                size: 34,
              ),
            ),
          ),
        Expanded(
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.primaryGreen, width: 1.4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText(context),
                        fontFamily: 'Montserrat',
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: 'Search Restaurant, dishes...',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6E6E6E),
                          fontFamily: 'Montserrat',
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 32,
                          color: Color(0xFF727272),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onFilterTap,
                  child: Container(
                    width: 84,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
