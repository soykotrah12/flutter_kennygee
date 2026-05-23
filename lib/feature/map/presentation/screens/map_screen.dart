import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/map_filter_model.dart';
import '../../data/models/map_restaurant_model.dart';
import '../controllers/map_controller.dart';
import '../widgets/map_filter_sheet.dart';
import '../widgets/map_path_dialog.dart';
import '../widgets/map_restaurant_preview_card.dart';
import '../widgets/map_route_info_sheet.dart';
import '../widgets/map_search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static int _buildCount = 0;
  late final MapFeatureController _controller;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    debugPrint('MAP SCREEN OPENED');
    _controller = MapFeatureController.ensureInitialized();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    debugPrint('[MapScreen] build count=$_buildCount');

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: GetBuilder<MapFeatureController>(
            id: 'map_widget',
            builder: (mapFeatureController) {
              debugPrint('GoogleMap building...');
              return GoogleMap(
                initialCameraPosition:
                    MapFeatureController.fallbackCameraPosition,
                onMapCreated: mapFeatureController.onMapCreated,
                onCameraMove: mapFeatureController.onCameraMove,
                onCameraIdle: mapFeatureController.onCameraIdle,
                myLocationEnabled:
                    mapFeatureController.userLocation.value != null,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                mapType: MapType.normal,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                markers: mapFeatureController.mapMarkers,
                polylines: mapFeatureController.mapPolylines,
                circles: mapFeatureController.mapCircles,
                onTap: (_) => mapFeatureController.clearSelection(),
              );
            },
          ),
        ),
        Obx(() {
          return Stack(children: _buildMarkerLabels());
        }),
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          right: 16,
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) {
              return MapSearchBar(
                controller: _searchController,
                onChanged: _controller.onSearchChanged,
                onFilterTap: _openFilter,
                showBackButton: value.text.trim().isNotEmpty,
                onBackTap: () {
                  _searchController.clear();
                  _controller.clearSearch();
                },
              );
            },
          ),
        ),
        Obx(() {
          if (!_controller.hasNoSearchResult) return const SizedBox.shrink();
          return Positioned(
            top: MediaQuery.of(context).padding.top + 84,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardSoft : const Color(0xF2FFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No restaurant found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          );
        }),
        Obx(() {
          if (_controller.isLoading.value) {
            return Positioned(
              top: MediaQuery.of(context).padding.top + 86,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                color: AppColors.primaryGreen,
                minHeight: 2,
                backgroundColor: isDark
                    ? AppColors.darkCardSoft
                    : Colors.white,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final String? message = _controller.locationMessage.value;
          if (message == null || message.isEmpty) {
            return const SizedBox.shrink();
          }
          return Positioned(
            top: MediaQuery.of(context).padding.top + 86,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardSoft : const Color(0xEEFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: TextStyle(
                  color: AppColors.secondaryText(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          );
        }),
        Obx(() {
          final MapRestaurantModel? selected =
              _controller.selectedRestaurant.value;
          final bool showRoute = _controller.routeModel.value != null;
          final double bottomOffset = showRoute
              ? 180
              : (selected != null ? 240 : 18);

          return Positioned(
            right: 18,
            bottom: bottomOffset,
            child: GestureDetector(
              onTap: _controller.goToCurrentLocation,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.cardColor(context),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ),
            ),
          );
        }),
        Obx(() {
          final MapRestaurantModel? selected =
              _controller.selectedRestaurant.value;
          final bool showRoute = _controller.routeModel.value != null;

          if (selected != null && !showRoute) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: MapRestaurantPreviewCard(
                restaurant: selected,
                image: _controller.resolveImage(selected.imageUrl),
                onViewDetails: _controller.openRestaurantDetails,
                onDirectionTap: _openPathDialog,
              ),
            );
          }

          if (showRoute) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapRouteInfoSheet(
                route: _controller.routeModel.value!,
                onClose: _controller.clearRoute,
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ],
    );
  }

  List<Widget> _buildMarkerLabels() {
    final MapRestaurantModel? selected = _controller.selectedRestaurant.value;

    return _controller.visibleRestaurants.map((restaurant) {
      final Offset? point = _controller.markerOffsets[restaurant.shopId];
      if (point == null) return const SizedBox.shrink();

      final bool isSelected = selected?.shopId == restaurant.shopId;

      return Positioned(
        left: point.dx - 85,
        top: point.dy + 26,
        child: IgnorePointer(
          child: Container(
            constraints: const BoxConstraints(minWidth: 108, maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFF3CB67)
                  : (AppColors.isDarkMode
                        ? AppColors.darkCardSoft
                        : AppColors.softCardColor(context)),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              restaurant.restaurantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _openFilter() async {
    final MapFilterModel? filter = await showModalBottomSheet<MapFilterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.96,
        child: MapFilterSheet(initialFilter: _controller.activeFilter.value),
      ),
    );

    if (filter != null) {
      _controller.applyFilter(filter);
    }
  }

  Future<void> _openPathDialog() async {
    final MapRestaurantModel? restaurant = _controller.selectedRestaurant.value;
    if (restaurant == null) return;

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x88000000),
      builder: (_) => MapPathDialog(
        restaurant: restaurant,
        onShowPath: (_) => _controller.buildRouteToSelectedRestaurant(),
      ),
    );
  }
}
