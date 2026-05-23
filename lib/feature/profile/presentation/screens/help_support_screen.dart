import 'package:flutter/material.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  late final ProfileController _profileController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _profileController = ensureProfileController();
    _emailController.selection = TextSelection.collapsed(
      offset: _emailController.text.length,
    );
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
    _prefillUserEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _sendSupportMessage() async {
    if (_isSending) return;

    final String email = _emailController.text.trim();
    final String subject = _subjectController.text.trim();
    final String description = _descriptionController.text.trim();

    if (email.isEmpty || subject.isEmpty || description.isEmpty) {
      if (email.isEmpty) {
        _showSnackBar('Unable to load your email. Please try again.');
      } else {
        _showSnackBar('Please fill in subject and description.');
      }
      return;
    }

    final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    setState(() {
      _isSending = true;
    });

    final result = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}/support',
      data: <String, dynamic>{
        'email': email,
        'subject': subject,
        'description': description,
      },
      fromJsonT: _asMap,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        _showSnackBar(failure.message);
      },
      (success) {
        _emailController.clear();
        _subjectController.clear();
        _descriptionController.clear();
        _showSnackBar(
          success.message.isNotEmpty
              ? success.message
              : 'Support message sent successfully',
          isSuccess: true,
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
    });
  }

  Future<void> _prefillUserEmail() async {
    final String currentEmail = _profileController.profile.value?.email.trim() ?? '';
    if (currentEmail.isNotEmpty) {
      _emailController.text = currentEmail;
      return;
    }

    await _profileController.fetchProfile(showLoader: false);
    if (!mounted) return;

    final String fetchedEmail = _profileController.profile.value?.email.trim() ?? '';
    if (fetchedEmail.isEmpty) return;

    _emailController.text = fetchedEmail;
    _emailController.selection = TextSelection.collapsed(
      offset: _emailController.text.length,
    );
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? AppColors.primaryGreen : Colors.red,
        ),
      );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: false,
      backgroundColor: AppColors.background(context),
      bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      appBarTitle: 'Help & Support',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Email',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            controller: _emailController,
            readOnly: true,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
              hintText: 'Enter your Email',
              hintStyle: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Montserrat',
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  Icons.person_outline,
                  size: 26,
                  color: AppColors.primaryText(context),
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
          Text(
            'Subject',
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            controller: _subjectController,
            decoration: InputDecoration(
              hintText: 'Problem Heading',
              hintStyle: TextStyle(
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
          Text(
            'Description',
            style: TextStyle(
              color: AppColors.primaryText(context),
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
            style: TextStyle(
              color: AppColors.primaryText(context),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
            ),
            decoration: InputDecoration(
              hintText: 'Description',
              hintStyle: TextStyle(
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
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ),
          const Spacer(),
          PrimaryButton(
            onPressed: _sendSupportMessage,
            isLoading: _isSending,
            height: 52,
            borderRadius: 8,
            child: Text(
              'Send',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
