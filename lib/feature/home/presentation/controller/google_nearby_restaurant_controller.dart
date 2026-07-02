import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../data/model/google_nearby_restaurant_model.dart';
import '../../data/repo/google_nearby_restaurant_repository.dart';

class GoogleNearbyRestaurantController extends GetxController {
  GoogleNearbyRestaurantController(this._repository);

  static const double fallbackLat = 23.8000;
  static const double fallbackLng = 90.4000;
  static const int defaultRadiusMeters = 10000;
  static const int pageSize = 20;

  final GoogleNearbyRestaurantRepository _repository;

  final RxList<GoogleNearbyRestaurantModel> restaurants =
      <GoogleNearbyRestaurantModel>[].obs;
  final RxList<GoogleNearbyRestaurantModel> displayedRestaurants =
      <GoogleNearbyRestaurantModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasLoaded = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt radiusMeters = defaultRadiusMeters.obs;
  final RxDouble minimumRating = 0.0.obs;
  final RxBool openNowOnly = false.obs;
  final RxInt totalRestaurants = 0.obs;

  Timer? _searchDebounce;
  LocationPermission? _cachedPermission;
  bool _hasRequestedLocationPermission = false;
  double _lat = fallbackLat;
  double _lng = fallbackLng;
  int _visibleCount = pageSize;
  int _requestSerial = 0;
  final Set<String> _successfulFetchKeys = <String>{};

  static GoogleNearbyRestaurantController ensureInitialized() {
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }

    if (!Get.isRegistered<GoogleNearbyRestaurantRepository>()) {
      Get.lazyPut<GoogleNearbyRestaurantRepository>(
        () =>
            GoogleNearbyRestaurantRepository(apiClient: Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<GoogleNearbyRestaurantController>()) {
      Get.put<GoogleNearbyRestaurantController>(
        GoogleNearbyRestaurantController(
          Get.find<GoogleNearbyRestaurantRepository>(),
        ),
      );
    }

    return Get.find<GoogleNearbyRestaurantController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchRestaurants();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  bool get hasMore => displayedRestaurants.length < filteredRestaurants.length;
  int get effectiveTotalCount {
    final int total = totalRestaurants.value;
    return total > 0 ? total : restaurants.length;
  }

  List<GoogleNearbyRestaurantModel> get filteredRestaurants {
    final double rating = minimumRating.value;
    final bool onlyOpen = openNowOnly.value;

    return restaurants.where((restaurant) {
      if (rating > 0 && restaurant.rating < rating) return false;
      if (onlyOpen && restaurant.isOpenNow != true) return false;
      return true;
    }).toList();
  }

  List<GoogleNearbyRestaurantModel> homeRestaurants({String query = ''}) {
    final String normalized = query.trim().toLowerCase();
    final Iterable<GoogleNearbyRestaurantModel> source = normalized.isEmpty
        ? restaurants
        : restaurants.where((restaurant) {
            return restaurant.title.toLowerCase().contains(normalized) ||
                restaurant.address.toLowerCase().contains(normalized);
          });
    return source.take(4).toList();
  }

  Future<void> fetchRestaurants({bool forceRefresh = false}) async {
    if (isLoading.value || isRefreshing.value) {
      debugPrint('GOOGLE NEARBY FETCH SKIPPED => already loading');
      return;
    }

    final String normalizedSearch = searchQuery.value.trim();
    final String cachedFetchKey = _buildFetchKey(
      lat: _lat,
      lng: _lng,
      radius: radiusMeters.value,
      search: normalizedSearch,
    );

    if (!forceRefresh &&
        hasLoaded.value &&
        _successfulFetchKeys.contains(cachedFetchKey)) {
      debugPrint('GOOGLE NEARBY FETCH SKIPPED => already loaded');
      return;
    }

    final _LocationPoint location = await _resolveLocation();
    final String fetchKey = _buildFetchKey(
      lat: location.lat,
      lng: location.lng,
      radius: radiusMeters.value,
      search: normalizedSearch,
    );

    if (!forceRefresh &&
        hasLoaded.value &&
        _successfulFetchKeys.contains(fetchKey)) {
      debugPrint('GOOGLE NEARBY FETCH SKIPPED => already loaded');
      return;
    }

    final int requestId = ++_requestSerial;
    if (forceRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    error.value = '';

    _lat = location.lat;
    _lng = location.lng;

    debugPrint(
      'GOOGLE NEARBY FETCH START => query="$normalizedSearch" '
      'radius=${radiusMeters.value}',
    );

    final result = await _repository.fetchRestaurants(
      lat: _lat,
      lng: _lng,
      radius: radiusMeters.value,
      search: normalizedSearch,
    );

    if (isClosed || requestId != _requestSerial) return;

    result.fold(
      (failure) {
        error.value = failure.message;
        restaurants.clear();
        displayedRestaurants.clear();
        totalRestaurants.value = 0;
      },
      (success) {
        restaurants.assignAll(success.data.restaurants);
        totalRestaurants.value = success.data.totalRestaurants > 0
            ? success.data.totalRestaurants
            : success.data.restaurants.length;
        hasLoaded.value = true;
        _successfulFetchKeys.add(fetchKey);
        _visibleCount = pageSize;
        _rebuildDisplayed();
        debugPrint(
          'GOOGLE NEARBY FETCH SUCCESS => total count '
          '$effectiveTotalCount',
        );
      },
    );

    if (!isClosed) {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshRestaurants() {
    return fetchRestaurants(forceRefresh: true);
  }

  void onSearchChanged(String value) {
    final String normalized = value.trim();
    if (normalized == searchQuery.value.trim()) return;
    searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _visibleCount = pageSize;
      fetchRestaurants();
    });
  }

  void setRadius(int meters) {
    if (radiusMeters.value == meters) return;
    radiusMeters.value = meters;
    _visibleCount = pageSize;
    fetchRestaurants();
  }

  void setMinimumRating(double rating) {
    minimumRating.value = rating;
    _visibleCount = pageSize;
    _rebuildDisplayed();
  }

  void toggleOpenNowOnly() {
    openNowOnly.value = !openNowOnly.value;
    _visibleCount = pageSize;
    _rebuildDisplayed();
  }

  Future<void> loadNextPage() async {
    if (!hasMore || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _visibleCount += pageSize;
    _rebuildDisplayed();
    isLoadingMore.value = false;
  }

  void _rebuildDisplayed() {
    displayedRestaurants.assignAll(filteredRestaurants.take(_visibleCount));
  }

  Future<_LocationPoint> _resolveLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const _LocationPoint(fallbackLat, fallbackLng);
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
        return const _LocationPoint(fallbackLat, fallbackLng);
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return _LocationPoint(position.latitude, position.longitude);
    } catch (error) {
      debugPrint('GOOGLE NEARBY RESTAURANTS LOCATION FALLBACK => $error');
      return const _LocationPoint(fallbackLat, fallbackLng);
    }
  }

  String _buildFetchKey({
    required double lat,
    required double lng,
    required int radius,
    required String search,
  }) {
    return '${lat.toStringAsFixed(4)}|'
        '${lng.toStringAsFixed(4)}|'
        '$radius|'
        '${search.trim().toLowerCase()}';
  }
}

class _LocationPoint {
  const _LocationPoint(this.lat, this.lng);

  final double lat;
  final double lng;
}
