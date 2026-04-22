import 'package:flutter/material.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjectController.selection = TextSelection.collapsed(
      offset: _subjectController.text.length,
    );
    _descriptionController.selection = TextSelection.collapsed(
      offset: _descriptionController.text.length,
    );
    _descriptionController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Help & Support',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Email',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              hintText: 'Enter your Email',
              hintStyle: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: AppColors.textBlack,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.textGrey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Subject',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Problem Heading',
              hintStyle: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 18,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.textGrey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Description',
            style: TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLength: 300,
            maxLines: 5,
            style: const TextStyle(
              color: AppColors.textBlack,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              counterText: '',
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.textGrey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.6,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_descriptionController.text.length}/300',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
