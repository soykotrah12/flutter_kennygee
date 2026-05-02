import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_kennegee/core/common/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/common/widgets/adaptive_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/food_model.dart';
import '../controller/owner_food_list_controller.dart';
import '../controller/owner_shop_controller.dart';
import 'owner_add_menu_screen.dart';

class OwnerAddShopScreen extends StatefulWidget {
  const OwnerAddShopScreen({super.key});

  @override
  State<OwnerAddShopScreen> createState() => _OwnerAddShopScreenState();
}

class _OwnerAddShopScreenState extends State<OwnerAddShopScreen> {
  late final OwnerShopController _controller;
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedImagePath;
  String? _remoteImageUrl;

  @override
  void initState() {
    super.initState();
    _controller = ensureOwnerShopController();

    final shop = _controller.ownerShop.value;
    _restaurantNameController.text = shop?.restaurantName ?? '';
    _descriptionController.text = shop?.description ?? '';
    _locationController.text = shop?.location.address ?? '123 Culinary Way';
    _remoteImageUrl = shop?.image.url;
    _controller.resetOperatingHoursFromShop(force: true);
  }

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickShopImage() async {
    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _selectedImagePath = picked.path;
    });
  }

  Future<void> _pickTime({required String day, required bool isOpen}) async {
    final String currentValue = isOpen
        ? _controller.getDayValue(day).open
        : _controller.getDayValue(day).close;
    final _TimeSelectionResult result = await _showOperatingTimeDialog(
      initialTime: _parseTimeOfDay(currentValue),
    );

    if (!mounted) return;

    if (result.isClosed) {
      _controller.markDayClosed(day);
      return;
    }

    final TimeOfDay? pickedTime = result.time;
    if (pickedTime == null) return;

    final int hour = pickedTime.hourOfPeriod == 0
        ? 12
        : pickedTime.hourOfPeriod;
    final String minute = pickedTime.minute.toString().padLeft(2, '0');
    final String period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
    final String value = '$hour:$minute $period';

    if (isOpen) {
      _controller.setOpenTime(day, value);
    } else {
      _controller.setCloseTime(day, value);
    }
  }

  Future<_TimeSelectionResult> _showOperatingTimeDialog({
    required TimeOfDay initialTime,
  }) async {
    bool isClosedAction = false;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext dialogContext, Widget? child) {
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodColor: WidgetStateColor.resolveWith((
                Set<WidgetState> states,
              ) {
                return states.contains(WidgetState.selected)
                    ? AppColors.primaryGreen
                    : Colors.transparent;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((
                Set<WidgetState> states,
              ) {
                return states.contains(WidgetState.selected)
                    ? Colors.white
                    : AppColors.textBlack;
              }),
            ),
          ),
          child: Stack(
            children: [
              if (child != null) child,
              Positioned(
                left: 16,
                bottom: 10,
                child: TextButton(
                  onPressed: () {
                    isClosedAction = true;
                    Navigator.of(dialogContext).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.logoutRed,
                    backgroundColor: const Color(0xFFF9E8E8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Closed',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (isClosedAction) {
      return const _TimeSelectionResult(isClosed: true);
    }

    return _TimeSelectionResult(time: pickedTime, isClosed: false);
  }

  TimeOfDay _parseTimeOfDay(String raw) {
    final RegExpMatch? match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*([aApP][mM])$',
    ).firstMatch(raw.trim());

    if (match == null) {
      return const TimeOfDay(hour: 9, minute: 0);
    }

    final int hour12 = int.tryParse(match.group(1) ?? '') ?? 9;
    final int minute = int.tryParse(match.group(2) ?? '') ?? 0;
    final String period = (match.group(3) ?? 'AM').toUpperCase();

    int hour24 = hour12 % 12;
    if (period == 'PM') {
      hour24 += 12;
    }

    return TimeOfDay(hour: hour24, minute: minute.clamp(0, 59));
  }

  Future<void> _submit() async {
    final String name = _restaurantNameController.text.trim();
    final String description = _descriptionController.text.trim();
    final String location = _locationController.text.trim();

    if (name.isEmpty || description.isEmpty || location.isEmpty) {
      Get.snackbar(
        'Validation',
        'Please fill all required shop fields.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    final bool success = await _controller.submitShop(
      restaurantName: name,
      description: description,
      address: location,
      latitude: 23.8103,
      longitude: 90.4125,
      imagePath: _selectedImagePath,
    );

    if (!success || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      isScrollable: true,
      appBarTitle: 'Add Your Shop',
      body: Obx(() {
        final existingShop = _controller.ownerShop.value;
        final String resolvedShopId = (existingShop?.shopId ?? '').trim();
        final String? shopId = resolvedShopId.isNotEmpty
            ? resolvedShopId
            : null;
        final bool isEditMode = existingShop != null || shopId != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Identity',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tell us about your brand\'s essence.',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickShopImage,
              borderRadius: BorderRadius.circular(20),
              child: CustomPaint(
                foregroundPainter: _DottedBorderPainter(
                  color: AppColors.primaryGreen,
                  radius: 20,
                  strokeWidth: 2,
                  dashWidth: 6,
                  gap: 5,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 113,
                  child: _buildImageContent(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Restaurant Name'),
            const SizedBox(height: 8),
            _textInput(
              controller: _restaurantNameController,
              hintText: 'e.g. The Golden Truffle',
            ),
            const SizedBox(height: 14),
            _fieldLabel('Description'),
            const SizedBox(height: 8),
            _textInput(
              controller: _descriptionController,
              hintText: 'Describe your culinary vision...',
              maxLines: 4,
            ),
            const SizedBox(height: 14),
            _fieldLabel('Location'),
            const SizedBox(height: 8),
            _textInput(
              controller: _locationController,
              hintText: '123 Culinary Way',
            ),
            const SizedBox(height: 20),
            const Text(
              'Operating Hours',
              style: TextStyle(
                color: AppColors.textBlack,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ...OwnerShopController.dayKeys.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _operatingHourRow(day),
              ),
            ),
            if (isEditMode && shopId != null) ...[
              const SizedBox(height: 14),
              _menuPreviewSection(shopId),
              const SizedBox(height: 14),
              _addFoodItemButton(shopId),
            ],
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _submit,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _controller.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        isEditMode ? 'Save Changes' : 'Save',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildImageContent() {
    if (_selectedImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    if (_remoteImageUrl != null && _remoteImageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AdaptiveImage(
          path: _remoteImageUrl!,
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
            color: Color(0xFFD9E2DF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: AppColors.primaryGreen, size: 28),
        ),
        const SizedBox(height: 10),
        const Text(
          'Add photo',
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF0F0F0),
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
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryGreen),
        ),
      ),
    );
  }

  Widget _operatingHourRow(String day) {
    final String dayLabel = '${day[0].toUpperCase()}${day.substring(1)}';
    final bool isClosed = _controller.isDayClosed(day);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Center(
              child: Text(
                dayLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                style: const TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isClosed
                ? Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () => _pickTime(day: day, isOpen: true),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E8E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Closed',
                          style: TextStyle(
                            color: AppColors.logoutRed,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _timeBox(
                          text: _controller.getDayOpenLabel(day),
                          onTap: () => _pickTime(day: day, isOpen: true),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '-',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _timeBox(
                          text: _controller.getDayCloseLabel(day),
                          onTap: () => _pickTime(day: day, isOpen: false),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _menuPreviewSection(String shopId) {
    final OwnerFoodListController ownerFoodCtrl =
        OwnerFoodListController.ensureInitialized(shopId);

    return Obx(() {
      if (ownerFoodCtrl.isLoading.value && ownerFoodCtrl.foods.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
        );
      }

      if (ownerFoodCtrl.foods.isEmpty) {
        return const SizedBox.shrink();
      }

      final List<FoodModel> foods = ownerFoodCtrl.foods.take(2).toList();
      return Column(
        children: [
          for (int i = 0; i < foods.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _FoodPreviewCard(item: foods[i]),
          ],
        ],
      );
    });
  }

  Widget _addFoodItemButton(String shopId) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () async {
          final bool? created = await Get.to<bool>(
            () => OwnerAddMenuScreen(shopId: shopId),
          );

          if (created == true && mounted) {
            await OwnerFoodListController.ensureInitialized(
              shopId,
            ).fetchShopFoods();
            Get.snackbar(
              'Success',
              'Menu item added successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primaryGreen,
              colorText: Colors.white,
              margin: const EdgeInsets.all(12),
            );
          }
        },
        icon: const Icon(Icons.add, color: Colors.white, size: 26),
        label: const Text(
          'Add Food Item',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFD1AE2F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _timeBox({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textBlack,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimeSelectionResult {
  const _TimeSelectionResult({this.time, required this.isClosed});

  final TimeOfDay? time;
  final bool isClosed;
}

class _FoodPreviewCard extends StatelessWidget {
  const _FoodPreviewCard({required this.item});

  final FoodModel item;

  @override
  Widget build(BuildContext context) {
    final bool hasFraction = item.price % 1 != 0;
    final String formattedPrice = hasFraction
        ? item.price.toStringAsFixed(2)
        : item.price.toStringAsFixed(0);
    final String imagePath = item.image.trim().isNotEmpty
        ? item.image
        : AppImages.food;
    final String name = item.name.trim().isNotEmpty
        ? item.name
        : 'Unnamed item';
    final String description = item.description.trim().isNotEmpty
        ? item.description
        : 'Food item';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AdaptiveImage(
              path: imagePath,
              width: 84,
              height: 84,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '\$$formattedPrice',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  _DottedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 2,
    this.dashWidth = 6,
    this.gap = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
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
      Radius.circular(radius),
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
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.radius != radius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap;
  }
}
