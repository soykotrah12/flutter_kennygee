import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class OwnerMapSearchBar extends StatelessWidget {
  const OwnerMapSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onSearchTap,
    required this.isSearching,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSearchTap;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGreen, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context, light: 0.08, dark: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, size: 22, color: AppColors.iconColor(context)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
                hintText: 'Search address, place or restaurant',
                hintStyle: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                ),
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: isSearching ? null : onSearchTap,
          //   child: Container(
          //     width: 54,
          //     height: double.infinity,
          //     decoration: BoxDecoration(
          //       color: AppColors.primaryGreen,
          //       borderRadius: const BorderRadius.horizontal(
          //         right: Radius.circular(13),
          //       ),
          //     ),
          //     child: Center(
          //       child: isSearching
          //           ? const SizedBox(
          //               width: 18,
          //               height: 18,
          //               child: CircularProgressIndicator(
          //                 strokeWidth: 2,
          //                 valueColor: AlwaysStoppedAnimation<Color>(
          //                   Colors.white,
          //                 ),
          //               ),
          //             )
          //           : const Icon(
          //               Icons.search_rounded,
          //               color: Colors.white,
          //               size: 22,
          //             ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
