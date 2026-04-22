import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicySecurityScreen extends StatelessWidget {
  const PrivacyPolicySecurityScreen({super.key});

  static const String _policyParagraph =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
      "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
      'when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.appBackground,
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Privacy policy & Security',
      body: Column(
        children: const [
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PolicyText(paragraph: _policyParagraph),
                  SizedBox(height: 30),
                  _PolicyText(paragraph: _policyParagraph),
                  SizedBox(height: 30),
                  _PolicyText(paragraph: _policyParagraph),
                  SizedBox(height: 30),
                  _PolicyText(paragraph: _policyParagraph),
                  SizedBox(height: 30),
                  _PolicyText(paragraph: _policyParagraph),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _PolicyText extends StatelessWidget {
  const _PolicyText({required this.paragraph});

  final String paragraph;

  @override
  Widget build(BuildContext context) {
    return Text(
      paragraph,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: 'Montserrat',
        height: 1.35,
      ),
    );
  }
}
