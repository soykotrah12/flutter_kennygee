import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/network/api_client.dart';
import '../../../home/presentation/screens/restaurant_details_screen.dart';
import '../../data/models/map_filter_model.dart';
import '../../data/models/map_place_result_model.dart';
import '../../data/models/map_restaurant_model.dart';
import '../../data/models/map_route_model.dart';
import '../../data/repositories/map_repository.dart';
import '../../data/services/map_place_search_service.dart';
import '../../data/services/map_route_service.dart';

class MapFeatureController extends GetxController {
  MapFeatureController(
    this._repository,
    this._routeService,
    this._placeSearchService,
  );

  static const CameraPosition fallbackCameraPosition = CameraPosition(
    target: LatLng(23.8403, 90.4125),
    zoom: 14,
  );

  final MapRepository _repository;
  final MapRouteService _routeService;
  final MapPlaceSearchService _placeSearchService;

  static MapFeatureController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<MapRepository>()) {
      Get.lazyPut<MapRepository>(
        () => MapRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MapRouteService>()) {
      Get.lazyPut<MapRouteService>(() => MapRouteService(), fenix: true);
    }

    if (!Get.isRegistered<MapPlaceSearchService>()) {
      Get.lazyPut<MapPlaceSearchService>(
        () => MapPlaceSearchService(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<MapFeatureController>()) {
      Get.put<MapFeatureController>(
        MapFeatureController(
          Get.find<MapRepository>(),
          Get.find<MapRouteService>(),
          Get.find<MapPlaceSearchService>(),
        ),
      );
    }

    return Get.find<MapFeatureController>();
  }

  final RxBool isLoading = false.obs;
  final RxList<MapRestaurantModel> allRestaurants = <MapRestaurantModel>[].obs;
  final RxList<MapRestaurantModel> visibleRestaurants =
      <MapRestaurantModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final Rx<MapFilterModel> activeFilter = MapFilterModel.defaults().obs;
  final Rxn<MapRestaurantModel> selectedRestaurant = Rxn<MapRestaurantModel>();
  final Rxn<LatLng> userLocation = Rxn<LatLng>();
  final RxnString locationMessage = RxnString();
  final Rxn<MapRouteModel> routeModel = Rxn<MapRouteModel>();
  final Rxn<MapPlaceResultModel> searchedPlaceResult =
      Rxn<MapPlaceResultModel>();
  final RxBool noSearchResult = false.obs;
  final RxMap<String, Offset> markerOffsets = <String, Offset>{}.obs;

  GoogleMapController? googleMapController;
  CameraPosition currentCamera = fallbackCameraPosition;

  Timer? _searchDebounceTimer;
  LocationPermission? _cachedPermission;
  bool _hasRequestedLocationPermission = false;
  bool _hasShownNoResultToast = false;
  int _searchSession = 0;

  Set<Marker> _mapMarkers = <Marker>{};
  Set<Polyline> _mapPolylines = <Polyline>{};
  Set<Circle> _mapCircles = <Circle>{};

  Set<Marker> get mapMarkers => _mapMarkers;
  Set<Polyline> get mapPolylines => _mapPolylines;
  Set<Circle> get mapCircles => _mapCircles;
  Set<Marker> get cachedMarkers => _mapMarkers;
  bool get hasNoSearchResult => noSearchResult.value;

  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _activeMarkerIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueYellow,
  );

  @override
  void onInit() {
    super.onInit();
    _prepareMarkerIcons();
    loadMapData();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    super.onClose();
  }

  Future<void> loadMapData() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final LatLng current = currentCamera.target;
    final List<MapRestaurantModel> restaurants = await _repository
        .fetchRestaurants(
          lat: current.latitude,
          lng: current.longitude,
          radiusKm: activeFilter.value.distanceKm,
        );
    final Map<String, List<String>> keywords = await _repository
        .fetchShopSearchKeywords();

    final List<MapRestaurantModel> merged = restaurants
        .map(
          (item) => item.copyWith(
            searchKeywords: keywords[item.shopId] ?? const <String>[],
          ),
        )
        .toList();

    debugPrint('restaurants loaded: ${merged.length}');

    allRestaurants.assignAll(merged);
    _applySearchAndFilter();
    isLoading.value = false;

    unawaited(_syncUserLocationAndCamera());
  }

  Future<void> _syncUserLocationAndCamera() async {
    final LatLng current = await _resolveUserLocation();
    if (googleMapController == null) return;
    await googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: current, zoom: 14.5),
      ),
    );
    await refreshMarkerOverlays();
  }

  Future<LatLng> _resolveUserLocation() async {
    final Position? position = await getCurrentLocation();
    if (position == null) {
      return fallbackCameraPosition.target;
    }

    final LatLng location = LatLng(position.latitude, position.longitude);
    userLocation.value = location;
    currentCamera = CameraPosition(target: location, zoom: 14.5);
    _rebuildMapLayers();
    return location;
  }

  Future<Position?> getCurrentLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationMessage.value = 'Location service is disabled.';
      return null;
    }

    LocationPermission permission =
        _cachedPermission ?? await Geolocator.checkPermission();

    if (permission == LocationPermission.denied &&
        !_hasRequestedLocationPermission) {
      _hasRequestedLocationPermission = true;
      permission = await Geolocator.requestPermission();
    }

    _cachedPermission = permission;

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      locationMessage.value = 'Location permission denied.';
      return null;
    }

    if (locationMessage.value != null && locationMessage.value!.isNotEmpty) {
      locationMessage.value = null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      locationMessage.value = 'Unable to fetch current location.';
      return null;
    }
  }

  void onMapCreated(GoogleMapController mapController) {
    debugPrint('onMapCreated called');
    googleMapController = mapController;
    _rebuildMapLayers();
    refreshMarkerOverlays();
  }

  void onCameraMove(CameraPosition position) {
    currentCamera = position;
  }

  Future<void> onCameraIdle() async {
    await refreshMarkerOverlays();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    isSearching.value = true;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 450), () {
      _applySearchAndFilter();
      isSearching.value = false;
    });
  }

  void clearSearch() {
    _searchDebounceTimer?.cancel();
    isSearching.value = false;
    searchQuery.value = '';
    _hasShownNoResultToast = false;
    searchedPlaceResult.value = null;
    _applySearchAndFilter();
  }

  void resetFilters() {
    activeFilter.value = MapFilterModel.defaults();
    _applySearchAndFilter();
  }

  void applyFilter(MapFilterModel filter) {
    activeFilter.value = filter;
    _applySearchAndFilter();
  }

  void selectRestaurant(MapRestaurantModel restaurant) {
    selectedRestaurant.value = restaurant;
    routeModel.value = null;
    _rebuildMapLayers();
    focusRestaurant(restaurant);
    refreshMarkerOverlays();
  }

  Future<void> focusRestaurant(MapRestaurantModel restaurant) async {
    if (googleMapController == null) return;
    await googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(restaurant.latitude, restaurant.longitude),
          zoom: 16,
        ),
      ),
    );
    await refreshMarkerOverlays();
  }

  void clearSelection() {
    selectedRestaurant.value = null;
    routeModel.value = null;
    _rebuildMapLayers();
    refreshMarkerOverlays();
  }

  void openRestaurantDetails() {
    final MapRestaurantModel? restaurant = selectedRestaurant.value;
    if (restaurant == null) return;
    Get.to(() => RestaurantDetailsScreen(shopId: restaurant.shopId));
  }

  Future<void> buildRouteToSelectedRestaurant() async {
    final MapRestaurantModel? restaurant = selectedRestaurant.value;
    if (restaurant == null) return;

    final Position? position = await getCurrentLocation();
    if (position == null) {
      Get.snackbar(
        'Location Required',
        locationMessage.value ?? 'Unable to get current location.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }

    final LatLng from = LatLng(position.latitude, position.longitude);
    final LatLng to = LatLng(restaurant.latitude, restaurant.longitude);

    userLocation.value = from;
    final MapRouteModel? route = await _routeService.buildWalkingRoute(
      from: from,
      to: to,
    );
    if (route == null) {
      Get.snackbar(
        'Route Unavailable',
        'Unable to fetch road-based direction right now.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }

    routeModel.value = route;
    _rebuildMapLayers();

    if (googleMapController != null) {
      final LatLngBounds bounds = _boundsFromPoints(<LatLng>[from, to]);
      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
      await refreshMarkerOverlays();
    }
  }

  void clearRoute() {
    routeModel.value = null;
    _rebuildMapLayers();
  }

  Future<void> goToCurrentLocation() async {
    final Position? position = await getCurrentLocation();
    if (position == null) {
      Get.snackbar(
        'Location',
        locationMessage.value ?? 'Unable to get current location.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
      );
      return;
    }

    final LatLng current = LatLng(position.latitude, position.longitude);
    userLocation.value = current;
    _rebuildMapLayers();

    if (googleMapController == null) return;
    await googleMapController!.animateCamera(
      CameraUpdate.newLatLngZoom(current, 15),
    );
    await refreshMarkerOverlays();
  }

  Future<void> moveToCurrentLocation() {
    return goToCurrentLocation();
  }

  Set<Marker> _buildMarkers() {
    final MapRestaurantModel? active = selectedRestaurant.value;
    final Set<Marker> markers = visibleRestaurants.map((restaurant) {
      final bool isActive = active?.shopId == restaurant.shopId;
      return Marker(
        markerId: MarkerId(restaurant.shopId),
        position: LatLng(restaurant.latitude, restaurant.longitude),
        icon: isActive ? _activeMarkerIcon : _markerIcon,
        consumeTapEvents: true,
        onTap: () => selectRestaurant(restaurant),
      );
    }).toSet();

    final MapPlaceResultModel? placeResult = searchedPlaceResult.value;
    if (placeResult != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('searched_place_marker'),
          position: placeResult.position,
          infoWindow: InfoWindow(
            title: placeResult.name,
            snippet: placeResult.formattedAddress,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    debugPrint('markers count: ${markers.length}');
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    final MapRouteModel? route = routeModel.value;
    if (route == null) return <Polyline>{};
    return <Polyline>{
      Polyline(
        polylineId: const PolylineId('active_route'),
        points: route.points,
        width: 6,
        color: const Color(0xFF0F4A39),
      ),
    };
  }

  Set<Circle> _buildCircles() {
    final LatLng? location = userLocation.value;
    if (location == null || routeModel.value == null) {
      return <Circle>{};
    }

    return <Circle>{
      Circle(
        circleId: const CircleId('user_radius'),
        center: location,
        radius: 120,
        fillColor: const Color(0x550F4A39),
        strokeColor: const Color(0x880F4A39),
        strokeWidth: 2,
      ),
    };
  }

  void _rebuildMapLayers() {
    _mapMarkers = _buildMarkers();
    _mapPolylines = _buildPolylines();
    _mapCircles = _buildCircles();
    update(<String>['map_widget']);
  }

  Future<void> refreshMarkerOverlays() async {
    final GoogleMapController? controller = googleMapController;
    if (controller == null) return;

    final Map<String, Offset> projected = <String, Offset>{};

    for (final MapRestaurantModel restaurant in visibleRestaurants) {
      try {
        final ScreenCoordinate screen = await controller.getScreenCoordinate(
          LatLng(restaurant.latitude, restaurant.longitude),
        );
        projected[restaurant.shopId] = Offset(
          screen.x.toDouble(),
          screen.y.toDouble(),
        );
      } catch (_) {}
    }

    markerOffsets.assignAll(projected);
  }

  void _applySearchAndFilter() {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      _hasShownNoResultToast = false;
      searchedPlaceResult.value = null;
      noSearchResult.value = false;
    }
    final MapFilterModel filter = activeFilter.value;

    final List<MapRestaurantModel> filterScoped = allRestaurants
        .where(
          (restaurant) =>
              restaurant.rating >= filter.minimumRating &&
              (!filter.openNowOnly || !restaurant.isClosedToday) &&
              _distanceFromLabel(restaurant.distanceLabel) <= filter.distanceKm,
        )
        .toList();

    final List<MapRestaurantModel> localQueryMatches = query.isEmpty
        ? filterScoped
        : filterScoped
              .where(
                (restaurant) =>
                    restaurant.restaurantName.toLowerCase().contains(query) ||
                    restaurant.address.toLowerCase().contains(query) ||
                    restaurant.searchKeywords.any(
                      (word) => word.toLowerCase().contains(query),
                    ),
              )
              .toList();

    final List<MapRestaurantModel> filtered = query.isEmpty
        ? filterScoped
        : (localQueryMatches.isNotEmpty ? localQueryMatches : filterScoped);

    visibleRestaurants.assignAll(filtered);

    final MapRestaurantModel? selected = selectedRestaurant.value;
    if (selected != null &&
        !filtered.any((item) => item.shopId == selected.shopId)) {
      selectedRestaurant.value = null;
      routeModel.value = null;
    }

    if (query.isNotEmpty && localQueryMatches.isNotEmpty) {
      _hasShownNoResultToast = false;
      noSearchResult.value = false;
      final MapRestaurantModel first = localQueryMatches.first;
      selectedRestaurant.value = first;
      searchedPlaceResult.value = null;
      unawaited(focusRestaurant(first));
    } else if (query.isNotEmpty && localQueryMatches.isEmpty) {
      noSearchResult.value = false;
      selectedRestaurant.value = null;
      routeModel.value = null;
      unawaited(_searchExternalPlace(query));
    }

    _rebuildMapLayers();
    unawaited(refreshMarkerOverlays());
  }

  Future<void> _searchExternalPlace(String query) async {
    final int activeSession = ++_searchSession;

    final MapPlaceResultModel? result = await _placeSearchService.searchPlace(
      query,
    );

    if (_searchSession != activeSession) return;

    if (result == null) {
      searchedPlaceResult.value = null;
      noSearchResult.value = true;
      if (!_hasShownNoResultToast) {
        _hasShownNoResultToast = true;
        Get.snackbar(
          'No Results',
          'No restaurant found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
      _rebuildMapLayers();
      return;
    }

    _hasShownNoResultToast = false;
    noSearchResult.value = false;
    searchedPlaceResult.value = result;
    _rebuildMapLayers();

    if (googleMapController != null) {
      await googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(result.position, 15),
      );
      await refreshMarkerOverlays();
    }
  }

  Future<void> _prepareMarkerIcons() async {
    _markerIcon = await _buildMarkerDescriptor(
      background: const Color(0xFF0F4A39),
      border: Colors.white,
      symbol: Colors.white,
    );

    _activeMarkerIcon = await _buildMarkerDescriptor(
      background: const Color(0xFF0F4A39),
      border: const Color(0xFFF3CB67),
      symbol: Colors.white,
    );

    _rebuildMapLayers();
  }

  Future<BitmapDescriptor> _buildMarkerDescriptor({
    required Color background,
    required Color border,
    required Color symbol,
  }) async {
    const double size = 116;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint shadow = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final Paint fill = Paint()..color = background;
    final Paint stroke = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(const Offset(size / 2, size / 2 + 2), 39, shadow);
    canvas.drawCircle(const Offset(size / 2, size / 2), 34, fill);
    canvas.drawCircle(const Offset(size / 2, size / 2), 34, stroke);

    final TextPainter iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.restaurant.codePoint),
        style: TextStyle(
          color: symbol,
          fontSize: 28,
          fontFamily: Icons.restaurant.fontFamily,
          package: Icons.restaurant.fontPackage,
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
      return BitmapDescriptor.defaultMarker;
    }

    return BitmapDescriptor.bytes(Uint8List.view(byteData.buffer));
  }

  double _distanceFromLabel(String label) {
    final RegExp regexp = RegExp(r'([0-9]+(\.[0-9]+)?)');
    final Match? match = regexp.firstMatch(label);
    if (match == null) return 9999;
    return double.tryParse(match.group(1) ?? '') ?? 9999;
  }

  LatLngBounds _boundsFromPoints(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  String resolveImage(String rawImage) {
    if (rawImage.trim().isEmpty) return AppImages.homeRestaurant1;
    return rawImage;
  }
}
