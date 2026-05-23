import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/map_restaurant_model.dart';

class MapPathDialog extends StatefulWidget {
  const MapPathDialog({
    super.key,
    required this.restaurant,
    required this.onShowPath,
  });

  final MapRestaurantModel restaurant;
  final Future<void> Function(String fromText) onShowPath;

  @override
  State<MapPathDialog> createState() => _MapPathDialogState();
}

class _MapPathDialogState extends State<MapPathDialog> {
  late final TextEditingController _fromController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
  }

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: const [
                      Icon(
                        Icons.circle_outlined,
                        color: AppColors.primaryGreen,
                        size: 18,
                      ),
                      SizedBox(height: 2),
                      Icon(Icons.more_vert, color: Color(0xFF7A7A7A), size: 24),
                      Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFF84545),
                        size: 29,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      _routeInput(
                        controller: _fromController,
                        hint: 'Search Restaurant, dishes...',
                        readonly: false,
                        boldText: null,
                      ),
                      const SizedBox(height: 10),
                      _routeInput(
                        controller: null,
                        hint: widget.restaurant.restaurantName,
                        readonly: true,
                        boldText: widget.restaurant.restaurantName,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _isLoading = true;
                        });
                        widget
                            .onShowPath(_fromController.text.trim())
                            .whenComplete(() {
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Show Path',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeInput({
    required TextEditingController? controller,
    required String hint,
    required bool readonly,
    required String? boldText,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? hint : null,
      readOnly: readonly,
      style: TextStyle(
        fontSize: boldText == null ? 16 : 19,
        fontWeight: boldText == null ? FontWeight.w400 : FontWeight.w700,
        color: boldText == null
            ? const Color(0xFF6F6F6F)
            : AppColors.primaryGreen,
        fontFamily: 'Montserrat',
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF7F7F7F),
          fontFamily: 'Montserrat',
        ),
        prefixIcon: readonly
            ? null
            : const Icon(Icons.search, size: 32, color: Color(0xFF6D6D6D)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
