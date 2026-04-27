import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/common/widgets/app_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../controller/owner_menu_update_controller.dart';
import '../../data/model/update_menu_response_model.dart';

class OwnerUpdateMenuScreen extends StatefulWidget {
  const OwnerUpdateMenuScreen({
    super.key,
    required this.menuId,
    required this.menuData,
  });

  final String menuId;
  final UpdateMenuResponseModel menuData;

  @override
  State<OwnerUpdateMenuScreen> createState() => _OwnerUpdateMenuScreenState();
}

class _OwnerUpdateMenuScreenState extends State<OwnerUpdateMenuScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _dishNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _discountController;

  late final OwnerMenuUpdateController _controller;
  late final String _tag;

  final List<String> _categories = <String>[
    'appetizer',
    'main course',
    'dessert',
    'beverage',
  ];

  late String _selectedCategory;
  late bool _isSpecialOffer;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _tag = 'menu_update_${widget.menuId}';
    _controller = ensureOwnerMenuUpdateController(
      menuId: widget.menuId,
      menuData: widget.menuData,
    );

    // Initialize with menu data
    _dishNameController = TextEditingController(text: widget.menuData.dishName);
    _descriptionController =
        TextEditingController(text: widget.menuData.description);
    _basePriceController =
        TextEditingController(text: widget.menuData.basePrice.toString());
    _discountController = TextEditingController(text: widget.menuData.offerText);

    // Validate category - ensure it matches one of the available options
    _selectedCategory = _categories.contains(widget.menuData.category.toLowerCase().trim())
        ? widget.menuData.category.toLowerCase().trim()
        : _categories.first;
    _isSpecialOffer = widget.menuData.specialOffer;
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _discountController.dispose();
    if (Get.isRegistered<OwnerMenuUpdateController>(tag: _tag)) {
      Get.delete<OwnerMenuUpdateController>(tag: _tag);
    }
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

  Future<void> _submitUpdate() async {
    await _controller.submitUpdate(
      dishName: _dishNameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      basePrice: double.tryParse(_basePriceController.text) ?? 0,
      specialOffer: _isSpecialOffer,
      offerText: _discountController.text.trim(),
      imagePath: _selectedImagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      appBarTitle: 'Update Menu',
      centerTitle: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _menuDetailsCard(),
          const SizedBox(height: 16),
          _specialOfferCard(),
          const SizedBox(height: 16),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _controller.isSubmitting.value ? null : _submitUpdate,
                style: TextButton.styleFrom(
                  backgroundColor: _controller.isSubmitting.value
                      ? AppColors.primaryGreen.withValues(alpha: 0.5)
                      : AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _controller.isDeleting.value
                    ? null
                    : _controller.deleteMenu,
                style: TextButton.styleFrom(
                  backgroundColor: _controller.isDeleting.value
                      ? Colors.red.withValues(alpha: 0.5)
                      : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _controller.isDeleting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Delete Menu Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            );
          }),
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
            hintText: 'Describe your menu item',
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
            hintText: 'e.g. 10',
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
              Obx(() {
                return Switch(
                  value: _isSpecialOffer,
                  onChanged: _controller.isTogglingOffer.value
                      ? null
                      : (value) {
                          setState(() {
                            _isSpecialOffer = value;
                          });
                        },
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primaryGreen,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFD4D4D4),
                );
              }),
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

    if (widget.menuData.images.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          widget.menuData.images.first.url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _defaultImageContent();
          },
        ),
      );
    }

    return _defaultImageContent();
  }

  Widget _defaultImageContent() {
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
