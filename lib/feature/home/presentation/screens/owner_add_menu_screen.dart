import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';

class OwnerAddMenuScreen extends StatefulWidget {
  const OwnerAddMenuScreen({super.key});

  @override
  State<OwnerAddMenuScreen> createState() => _OwnerAddMenuScreenState();
}

class _OwnerAddMenuScreenState extends State<OwnerAddMenuScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();

  final List<String> _categories = <String>[
    'appetizer',
    'main course',
    'dessert',
    'beverage',
  ];

  String _selectedCategory = 'appetizer';
  bool _isSpecialOffer = true;
  String? _selectedImagePath;

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickMenuImage() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _selectedImagePath = picked.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      appBarTitle: 'Add Menu',
      centerTitle: false,
      // titlespacing: 10,
      // bodyPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _menuDetailsCard(),
          const SizedBox(height: 16),
          _specialOfferCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Get.back();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Save Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuDetailsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _pickMenuImage,
            borderRadius: BorderRadius.circular(8),
            child: CustomPaint(
              foregroundPainter: const _MenuDottedBorderPainter(),
              child: SizedBox(
                width: double.infinity,
                height: 113,
                child: _menuImageContent(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _label('Dish Name'),
          const SizedBox(height: 8),
          _textInput(
            controller: _dishNameController,
            hintText: 'e.g. Burger & Pizza',
          ),
          const SizedBox(height: 12),
          _label('Description'),
          const SizedBox(height: 8),
          _textInput(
            controller: _descriptionController,
            hintText: 'Describe what makes your event special',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _label('Category'),
          const SizedBox(height: 8),
          _categoryDropdown(),
          const SizedBox(height: 12),
          _label('Base Price'),
          const SizedBox(height: 8),
          _textInput(
            controller: _basePriceController,
            hintText: 'e.g. \$10',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _specialOfferCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Special Offer',
                  style: TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Switch(
                
                value: _isSpecialOffer,
                onChanged: (value) {
                  setState(() {
                    _isSpecialOffer = value;
                  });
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primaryGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD4D4D4),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Give offer to the client',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          _textInput(
            controller: _discountController,
            hintText: 'e.g. 10% discount',
            enabled: _isSpecialOffer,
          ),
        ],
      ),
    );
  }

  Widget _menuImageContent() {
    if (_selectedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFDCE5E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.primaryGreen,
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Add photo',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _label(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }

  Widget _categoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCategory,
        borderRadius: BorderRadius.circular(12),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _categories
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedCategory = value;
          });
        },
      ),
    );
  }
}

class _MenuDottedBorderPainter extends CustomPainter {
  const _MenuDottedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const Color color = AppColors.primaryGreen;
    const double radius = 16;
    const double strokeWidth = 2;
    const double dashWidth = 4;
    const double gap = 10;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final RRect outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      const Radius.circular(radius),
    );

    final Path path = Path()..addRRect(outer);
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MenuDottedBorderPainter oldDelegate) {
    return false;
  }
}
