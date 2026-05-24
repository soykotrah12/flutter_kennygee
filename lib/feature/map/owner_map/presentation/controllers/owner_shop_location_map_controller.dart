import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../home/data/model/create_shop_response_model.dart';
import '../../../../home/presentation/controller/owner_shop_controller.dart';
import '../../../data/models/map_place_result_model.dart';
import '../../../data/services/map_place_search_service.dart';
import '../../data/models/owner_map_location_selection_model.dart';
import '../../data/services/owner_map_geocode_service.dart';

class OwnerShopLocationMapController extends GetxController {
  OwnerShopLocationMapController({
    MapPlaceSearchService? placeSearchService,
    OwnerMapGeocodeService? geocodeService,
  }) : _placeSearchService = placeSearchService ?? MapPlaceSearchService(),
       _geocodeService = geocodeService ?? OwnerMapGeocodeService();

  static const LatLng dhakaFallback = LatLng(23.8103, 90.4125);
  static const CameraPosition fallbackCameraPosition = CameraPosition(
    target: dhakaFallback,
    zoom: 14.6,
  );

  final MapPlaceSearchService _placeSearchService;
  final OwnerMapGeocodeService _geocodeService;

  GoogleMapController? googleMapController;

  Set<Marker> _mapMarkers = <Marker>{};
  Set<Circle> _mapCircles = <Circle>{};

  BitmapDescriptor _actualShopMarkerIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
  BitmapDescriptor _tempPinMarkerIcon = BitmapDescriptor.defaultMarker;

  LatLng _actualShopPosition = dhakaFallback;
  LatLng? _tempSelectedPosition;

  String _actualShopAddress = 'Dhaka';
  String _tempSelectedAddress = '';

  String _shopName = 'My Restaurant';
  String _shopImageUrl = '';

  bool _isSearching = false;
  bool _isResolvingAddress = false;
  bool _showMarkerInfoCard = false;
  bool _isLocatingCurrent = false;

  int _addressResolveToken = 0;
  Timer? _searchDebounceTimer;
  String _lastNoResultQuery = '';

  Set<Marker> get mapMarkers => _mapMarkers;
  Set<Circle> get mapCircles => _mapCircles;

  LatLng get actualShopLatLng => _actualShopPosition;
  LatLng? get tempSelectedLatLng => _tempSelectedPosition;

  String get shopName => _shopName;
  String get shopAddress => _actualShopAddress;
  String get shopImageUrl => _shopImageUrl;

  bool get isSearching => _isSearching;
  bool get isResolvingAddress => _isResolvingAddress;
  bool get showMarkerInfoCard => _showMarkerInfoCard;
  bool get isLocatingCurrent => _isLocatingCurrent;

  bool get hasTempSelection => _tempSelectedPosition != null;
  bool get hasUnsavedChanges => hasTempSelection;

  String get previewAddress => hasTempSelection
      ? (_tempSelectedAddress.trim().isEmpty
            ? _actualShopAddress
            : _tempSelectedAddress)
      : _actualShopAddress;

  OwnerMapLocationSelectionModel get currentSelection =>
      OwnerMapLocationSelectionModel(
        address: previewAddress,
        latitude: hasTempSelection
            ? _tempSelectedPosition!.latitude
            : _actualShopPosition.latitude,
        longitude: hasTempSelection
            ? _tempSelectedPosition!.longitude
            : _actualShopPosition.longitude,
      );

  void initialize({
    String? initialAddress,
    double? initialLatitude,
    double? initialLongitude,
  }) {
    final LatLng? incomingLocation = _toLatLngOrNull(
      initialLatitude,
      initialLongitude,
    );

    _actualShopPosition = incomingLocation ?? dhakaFallback;
    _actualShopAddress = _resolvedAddress(
      preferredAddress: initialAddress,
      shopAddress: '',
    );

    debugPrint(
      'OWNER initial location => ${_actualShopPosition.latitude},${_actualShopPosition.longitude}',
    );

    _rebuildMapLayers();
    update(<String>['map_widget', 'search', 'overlay']);

    unawaited(_prepareMarkerIcons());
    unawaited(
      _hydrateFromOwnerShopLocation(
        shouldOverridePosition: incomingLocation == null,
        shouldOverrideAddress: (initialAddress ?? '').trim().isEmpty,
      ),
    );
  }

  void onMapCreated(GoogleMapController mapController) {
    debugPrint('OWNER onMapCreated called');
    googleMapController = mapController;
    _rebuildMapLayers();
    update(<String>['map_widget']);

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_actualShopPosition, 15),
    );
  }

  void onMapTap(LatLng position) {
    _closeMarkerInfoCard();
    unawaited(_setTempSelection(position, resolveAddress: true));
  }

  void onActualShopMarkerTapped() {
    _showMarkerInfoCard = true;
    update(<String>['overlay']);
  }

  void onTempMarkerDragStart(LatLng _) {
    _closeMarkerInfoCard();
  }

  void onTempMarkerDrag(LatLng position) {
    _tempSelectedPosition = position;
    _rebuildMapLayers();
    update(<String>['map_widget', 'overlay']);
  }

  Future<void> onTempMarkerDragEnd(LatLng position) async {
    _closeMarkerInfoCard();
    await _setTempSelection(position, resolveAddress: true);
  }

  void onSearchChanged(String query) {
    final String trimmed = query.trim();
    _searchDebounceTimer?.cancel();

    if (trimmed.isEmpty) {
      _isSearching = false;
      _lastNoResultQuery = '';
      update(<String>['search']);
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 450), () {
      unawaited(_performSearch(trimmed, showErrorSnackbar: false));
    });
  }

  Future<void> searchAndSelectLocation(String query) async {
    _searchDebounceTimer?.cancel();
    await _performSearch(query.trim(), showErrorSnackbar: true);
  }

  Future<void> moveToCurrentLocationAsTemp() async {
    _closeMarkerInfoCard();

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackbar('Location service is disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showErrorSnackbar('Location permission denied.');
      return;
    }

    _isLocatingCurrent = true;
    update(<String>['overlay']);

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng current = LatLng(position.latitude, position.longitude);
      final GoogleMapController? controller = googleMapController;
      if (controller != null) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(current, 15.8),
        );
      }

      await _setTempSelection(current, resolveAddress: true);
    } catch (_) {
      _showErrorSnackbar('Unable to fetch current location.');
    } finally {
      _isLocatingCurrent = false;
      update(<String>['overlay']);
    }
  }

  OwnerMapLocationSelectionModel? applyTempSelection() {
    final LatLng? temp = _tempSelectedPosition;
    if (temp == null) return null;

    _actualShopPosition = temp;
    if (_tempSelectedAddress.trim().isNotEmpty) {
      _actualShopAddress = _tempSelectedAddress;
    }

    _tempSelectedPosition = null;
    _tempSelectedAddress = '';

    _rebuildMapLayers();
    update(<String>['map_widget', 'overlay']);

    return OwnerMapLocationSelectionModel(
      address: _actualShopAddress,
      latitude: _actualShopPosition.latitude,
      longitude: _actualShopPosition.longitude,
    );
  }

  void clearTempSelection() {
    _tempSelectedPosition = null;
    _tempSelectedAddress = '';
    _rebuildMapLayers();
    update(<String>['map_widget', 'overlay']);
  }

  Future<void> _performSearch(
    String cleaned, {
    required bool showErrorSnackbar,
  }) async {
    if (cleaned.isEmpty) return;

    _closeMarkerInfoCard();
    _isSearching = true;
    update(<String>['search']);

    final MapPlaceResultModel? result = await _placeSearchService.searchPlace(
      cleaned,
    );

    _isSearching = false;
    update(<String>['search']);

    if (result == null) {
      if (showErrorSnackbar && _lastNoResultQuery != cleaned) {
        _lastNoResultQuery = cleaned;
        _showErrorSnackbar('No place found for "$cleaned"');
      }
      return;
    }

    _lastNoResultQuery = '';

    final GoogleMapController? controller = googleMapController;
    if (controller != null) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(result.position, 15.8),
      );
    }

    await _setTempSelection(
      result.position,
      resolvedAddress: result.formattedAddress.trim().isEmpty
          ? result.name
          : result.formattedAddress,
      resolveAddress: false,
    );
  }

  Future<void> _setTempSelection(
    LatLng position, {
    String? resolvedAddress,
    required bool resolveAddress,
  }) async {
    _tempSelectedPosition = position;
    if (resolvedAddress != null && resolvedAddress.trim().isNotEmpty) {
      _tempSelectedAddress = resolvedAddress;
    }

    _rebuildMapLayers();
    update(<String>['map_widget', 'overlay']);

    if (resolveAddress) {
      await _resolveAddressForTempSelection();
    }
  }

  Future<void> _hydrateFromOwnerShopLocation({
    required bool shouldOverridePosition,
    required bool shouldOverrideAddress,
  }) async {
    try {
      final OwnerShopController ownerShopController =
          ensureOwnerShopController();

      if (ownerShopController.ownerShop.value == null) {
        await ownerShopController.refreshShop();
      }

      final CreateShopResponseModel? shop = ownerShopController.ownerShop.value;
      if (shop != null) {
        final _OwnerLocationSnapshot fromShop = _readShopLocation(shop);

        _shopName = shop.restaurantName.trim().isEmpty
            ? _shopName
            : shop.restaurantName;
        _shopImageUrl = shop.image.url;

        if (shouldOverridePosition) {
          _actualShopPosition = fromShop.position ?? dhakaFallback;
        }

        if (shouldOverrideAddress) {
          _actualShopAddress = _resolvedAddress(
            preferredAddress: null,
            shopAddress: fromShop.address,
          );
        }
      }

      debugPrint(
        'OWNER initial location => ${_actualShopPosition.latitude},${_actualShopPosition.longitude}',
      );

      _rebuildMapLayers();
      update(<String>['map_widget', 'overlay']);

      final GoogleMapController? controller = googleMapController;
      if (controller != null) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(_actualShopPosition, 15),
        );
      }
    } catch (_) {
      _rebuildMapLayers();
      update(<String>['map_widget', 'overlay']);
    }
  }

  Future<void> _resolveAddressForTempSelection() async {
    final LatLng? temp = _tempSelectedPosition;
    if (temp == null) return;

    final int token = ++_addressResolveToken;
    _isResolvingAddress = true;
    update(<String>['overlay']);

    final String? address = await _geocodeService.reverseGeocode(
      latitude: temp.latitude,
      longitude: temp.longitude,
    );

    if (token != _addressResolveToken) return;

    if (address != null && address.trim().isNotEmpty) {
      _tempSelectedAddress = address;
    }

    _isResolvingAddress = false;
    update(<String>['overlay']);
  }

  void _closeMarkerInfoCard() {
    if (!_showMarkerInfoCard) return;
    _showMarkerInfoCard = false;
    update(<String>['overlay']);
  }

  void _rebuildMapLayers() {
    final Set<Marker> markers = <Marker>{
      Marker(
        markerId: const MarkerId('owner_actual_shop_marker'),
        position: _actualShopPosition,
        draggable: false,
        icon: _actualShopMarkerIcon,
        infoWindow: InfoWindow(title: _shopName, snippet: _actualShopAddress),
        onTap: onActualShopMarkerTapped,
      ),
    };

    final LatLng? temp = _tempSelectedPosition;
    if (temp != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('owner_temp_selected_pin'),
          position: temp,
          draggable: true,
          icon: _tempPinMarkerIcon,
          onDragStart: onTempMarkerDragStart,
          onDrag: onTempMarkerDrag,
          onDragEnd: onTempMarkerDragEnd,
        ),
      );
    }

    final Set<Circle> circles = <Circle>{
      Circle(
        circleId: const CircleId('owner_actual_shop_radius_circle'),
        center: _actualShopPosition,
        radius: 3000,
        fillColor: const Color(0x3345A675),
        strokeColor: const Color(0xAA0F4A39),
        strokeWidth: 2,
      ),
    };

    if (temp != null) {
      circles.add(
        Circle(
          circleId: const CircleId('owner_temp_preview_radius_circle'),
          center: temp,
          radius: 3000,
          fillColor: const Color(0x1F2E86DE),
          strokeColor: const Color(0x993F93E8),
          strokeWidth: 1,
        ),
      );
    }

    _mapMarkers = markers;
    _mapCircles = circles;

    debugPrint('OWNER markers count => ${_mapMarkers.length}');
  }

  Future<void> _prepareMarkerIcons() async {
    _actualShopMarkerIcon = await _buildActualShopMarkerDescriptor();
    _tempPinMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueRed,
    );
    _rebuildMapLayers();
    update(<String>['map_widget']);
  }

  Future<BitmapDescriptor> _buildActualShopMarkerDescriptor() async {
    const double size = 80;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint shadow = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final Paint fill = Paint()..color = const Color(0xFF0F4A39);
    final Paint stroke = Paint()
      ..color = const Color(0xFFF3CB67)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(const Offset(size / 2, size / 2 + 2), 24, shadow);
    canvas.drawCircle(const Offset(size / 2, size / 2), 20, fill);
    canvas.drawCircle(const Offset(size / 2, size / 2), 20, stroke);

    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.storefront.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: Icons.storefront.fontFamily,
          package: Icons.storefront.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      Offset((size - iconPainter.width) / 2, (size - iconPainter.height) / 2),
    );

    final ui.Image image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    return BitmapDescriptor.bytes(Uint8List.view(byteData.buffer));
  }

  String _resolvedAddress({
    required String? preferredAddress,
    required String shopAddress,
  }) {
    final String fromInput = (preferredAddress ?? '').trim();
    if (fromInput.isNotEmpty) return fromInput;

    if (shopAddress.trim().isNotEmpty) return shopAddress.trim();

    return 'Dhaka';
  }

  _OwnerLocationSnapshot _readShopLocation(CreateShopResponseModel shop) {
    final List<double> coordinates = shop.location.coordinates;
    if (coordinates.length < 2) {
      return _OwnerLocationSnapshot(address: shop.location.address);
    }

    final double lng = coordinates[0];
    final double lat = coordinates[1];
    if (!_isValidLatLng(lat, lng)) {
      return _OwnerLocationSnapshot(address: shop.location.address);
    }

    return _OwnerLocationSnapshot(
      position: LatLng(lat, lng),
      address: shop.location.address,
    );
  }

  LatLng? _toLatLngOrNull(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return null;
    if (!_isValidLatLng(latitude, longitude)) return null;
    return LatLng(latitude, longitude);
  }

  bool _isValidLatLng(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Location',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    googleMapController?.dispose();
    super.onClose();
  }
}

class _OwnerLocationSnapshot {
  const _OwnerLocationSnapshot({this.position, this.address = ''});

  final LatLng? position;
  final String address;
}
