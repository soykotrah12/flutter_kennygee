import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/map_filter_model.dart';

class MapFilterSheet extends StatefulWidget {
  const MapFilterSheet({super.key, required this.initialFilter});

  final MapFilterModel initialFilter;

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late double _distance;
  late double _minimumRating;
  late bool _openNow;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialFilter.distanceKm;
    _minimumRating = widget.initialFilter.minimumRating;
    _openNow = widget.initialFilter.openNowOnly;
    _priceController = TextEditingController(
      text: widget.initialFilter.priceRange,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _resetAll() {
    setState(() {
      _distance = 12;
      _minimumRating = 4;
      _openNow = false;
      _priceController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        color: AppColors.softCardColor(context),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Search Filters',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _resetAll,
                          child: Text(
                            'Reset All',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFC2C2C2), thickness: 1.6),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Text(
                          'Distance Range',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_distance.round()}km',
                          style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _distance,
                      min: 0,
                      max: 20,
                      activeColor: AppColors.primaryGreen,
                      inactiveColor: const Color(0xFFE7E7E7),
                      onChanged: (value) {
                        setState(() {
                          _distance = value;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          '0km',
                          style: TextStyle(
                            color: Color(0xFF6F6F6F),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        Spacer(),
                        Text(
                          '20km',
                          style: TextStyle(
                            color: Color(0xFF6F6F6F),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Minimum Rating',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          _ratingButton(3),
                          _ratingButton(4),
                          _ratingButton(4.5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Price Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        hintText: 'Price',
                        hintStyle: TextStyle(
                          color: Color(0xFFBFBFBF),
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFBBBBBB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Text(
                          'Open Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _openNow,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primaryGreen,
                          onChanged: (value) {
                            setState(() {
                              _openNow = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      'Only show places currently open',
                      style: TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    MapFilterModel(
                      distanceKm: _distance,
                      minimumRating: _minimumRating,
                      priceRange: _priceController.text.trim(),
                      openNowOnly: _openNow,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Show On Map',
                  style: TextStyle(
                    fontSize: 22,
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

  Expanded _ratingButton(double rating) {
    final bool isSelected = _minimumRating == rating;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _minimumRating = rating;
          });
        },
        child: Container(
          height: 72,
          margin: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: isSelected ? Colors.white : const Color(0xFF6D6366),
                ),
                const SizedBox(width: 8),
                Text(
                  '${rating == rating.toInt() ? rating.toInt() : rating}+',
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6D6366),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
