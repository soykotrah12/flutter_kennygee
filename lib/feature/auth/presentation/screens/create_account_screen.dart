import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_buttoms.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/auth_flow_controller.dart';
import 'logIn_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, required this.selectedRole});

  final AppUserRole selectedRole;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  late final AuthFlowController _flowController;

  @override
  void initState() {
    super.initState();
    _flowController = ensureAuthFlowController();
    _flowController.selectRole(widget.selectedRole);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      backgroundColor: AppColors.background(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          children: [
            // const SizedBox(height: ),
            Image.asset(
              AppImages.appLogo,
              width: 59,
              height: 95,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 4),
            Text(
              'Let’s Get Started!',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create an account as ${widget.selectedRole.title}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: AppColors.primaryText(context),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 22),
            const _FormLabel('User  Name'),
            const SizedBox(height: 10),
            _AuthInput(
              controller: _nameController,
              hintText: 'Enter your First Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            const _FormLabel('Your Email'),
            const SizedBox(height: 10),
            _AuthInput(
              controller: _emailController,
              hintText: 'Enter your Email',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            const _FormLabel('Phone Number (Optional)'),
            const SizedBox(height: 10),
            _AuthInput(
              controller: _phoneController,
              hintText: 'Enter your phone number',
              prefixIcon: Icons.call_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const _FormLabel('Password'),
            const SizedBox(height: 10),
            _AuthInput(
              controller: _passwordController,
              hintText: 'Enter your Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                iconSize: 22,
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.secondaryText(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _FormLabel('Confirm Password'),
            const SizedBox(height: 10),
            _AuthInput(
              controller: _confirmPasswordController,
              hintText: 'Enter Confirm Password',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscureConfirm,
              suffixIcon: IconButton(
                iconSize: 22,
                onPressed: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.secondaryText(context),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Obx(
              () => PrimaryButton(
                height: 51,
                isLoading: _flowController.isSubmitting.value,
                onPressed: () => _flowController.signUp(
                  fullName: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  password: _passwordController.text,
                  confirmPassword: _confirmPasswordController.text,
                  role: widget.selectedRole,
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.off(() => const LoginRoleScreen()),
                  child: const Text(
                    'Sign In Here',
                    style: TextStyle(
                      color: AppColors.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: AppColors.primaryText(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: AppColors.primaryText(context),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: AppColors.secondaryText(context),
          size: 22,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
