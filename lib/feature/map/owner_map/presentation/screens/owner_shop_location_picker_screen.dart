import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../data/models/owner_map_location_selection_model.dart';
import '../controllers/owner_shop_location_map_controller.dart';
import '../widgets/owner_map_marker_info_card.dart';
import '../widgets/owner_map_search_bar.dart';
import '../widgets/owner_map_unsaved_action_bar.dart';

class OwnerShopLocationPickerScreen extends StatefulWidget {
  const OwnerShopLocationPickerScreen({
    super.key,
    required this.isPickerMode,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  final bool isPickerMode;
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<OwnerShopLocationPickerScreen> createState() =>
      _OwnerShopLocationPickerScreenState();
}

class _OwnerShopLocationPickerScreenState
    extends State<OwnerShopLocationPickerScreen> {
  late final OwnerShopLocationMapController _controller;
  late final String _controllerTag;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    debugPrint('OWNER MAP SCREEN OPENED');
    _controllerTag =
        'owner_map_${DateTime.now().microsecondsSinceEpoch.toString()}';
    _controller = Get.put(
      OwnerShopLocationMapController(),
      tag: _controllerTag,
    );
    _searchController = TextEditingController();

    _controller.initialize(
      initialAddress: widget.initialAddress,
      initialLatitude: widget.initialLatitude,
      initialLongitude: widget.initialLongitude,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (Get.isRegistered<OwnerShopLocationMapController>(tag: _controllerTag)) {
      Get.delete<OwnerShopLocationMapController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: widget.isPickerMode
          ? AppBar(title: const Text('Pick Location'), centerTitle: false)
          : null,
      body: SafeArea(
        top: !widget.isPickerMode,
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: GetBuilder<OwnerShopLocationMapController>(
                tag: _controllerTag,
                id: 'map_widget',
                builder: (controller) {
                  debugPrint('OWNER GoogleMap building...');
                  return GoogleMap(
                    initialCameraPosition:
                        OwnerShopLocationMapController.fallbackCameraPosition,
                    onMapCreated: controller.onMapCreated,
                    onTap: controller.onMapTap,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                    markers: controller.mapMarkers,
                    circles: controller.mapCircles,
                  );
                },
              ),
            ),
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: GetBuilder<OwnerShopLocationMapController>(
                tag: _controllerTag,
                id: 'search',
                builder: (controller) {
                  return OwnerMapSearchBar(
                    controller: _searchController,
                    onChanged: controller.onSearchChanged,
                    onSubmitted: controller.searchAndSelectLocation,
                    onSearchTap: () => controller.searchAndSelectLocation(
                      _searchController.text,
                    ),
                    isSearching: controller.isSearching,
                  );
                },
              ),
            ),
            GetBuilder<OwnerShopLocationMapController>(
              tag: _controllerTag,
              id: 'overlay',
              builder: (controller) {
                final bool showUnsavedBar = controller.hasTempSelection;
                final bool showInfoCard = controller.showMarkerInfoCard;

                return Stack(
                  children: [
                    Positioned(
                      right: 12,
                      bottom: showUnsavedBar ? 94 : 18,
                      child: GestureDetector(
                        onTap: controller.isLocatingCurrent
                            ? null
                            : controller.moveToCurrentLocationAsTemp,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cardColor(context),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow(
                                  context,
                                  light: 0.08,
                                  dark: 0.2,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: controller.isLocatingCurrent
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
  Icons.my_location_rounded,
  color: Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : AppColors.primaryGreen,
  size: 24,
),
                        ),
                      ),
                    ),
                    if (showInfoCard)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: showUnsavedBar ? 84 : 12,
                        child: OwnerMapMarkerInfoCard(
                          shopName: controller.shopName,
                          shopAddress: controller.shopAddress,
                          shopImage: controller.shopImageUrl,
                        ),
                      ),
                    if (showUnsavedBar)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: SafeArea(
                          top: false,
                          child: OwnerMapUnsavedActionBar(
                            address: controller.previewAddress,
                            latitude: controller.currentSelection.latitude,
                            longitude: controller.currentSelection.longitude,
                            isResolvingAddress: controller.isResolvingAddress,
                            onCancel: controller.clearTempSelection,
                            onUseLocation: () {
                              final OwnerMapLocationSelectionModel? selection =
                                  controller.applyTempSelection();
                              if (selection == null) return;

                              if (widget.isPickerMode) {
                                Get.back<OwnerMapLocationSelectionModel>(
                                  result: selection,
                                );
                                return;
                              }

                              Get.snackbar(
                                'Location Selected',
                                'Temporary location applied successfully.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: AppColors.primaryGreen,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(12),
                                duration: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
