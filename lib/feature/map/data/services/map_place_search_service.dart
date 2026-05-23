import 'package:dio/dio.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/map_place_result_model.dart';

class MapPlaceSearchService {
  MapPlaceSearchService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _mapsApiKey = 'AIzaSyClug6MI9bNV5pX50D6ugaFBi5TKTXCqIs';
  static const String _mapsBase = 'https://maps.googleapis.com/maps/api';

  final Dio _dio;

  Future<MapPlaceResultModel?> searchPlace(String query) async {
    final String sanitizedQuery = query.trim();
    if (sanitizedQuery.isEmpty) return null;

    final MapPlaceResultModel? placesResult = await _searchByPlacesText(
      sanitizedQuery,
    );
    if (placesResult != null) return placesResult;

    return _searchByGeocoding(sanitizedQuery);
  }

  Future<MapPlaceResultModel?> _searchByPlacesText(String query) async {
    try {
      final Response<dynamic> response = await _dio.get(
        '$_mapsBase/place/textsearch/json',
        queryParameters: <String, dynamic>{'query': query, 'key': _mapsApiKey},
      );

      final Map<String, dynamic> payload = _asMap(response.data);
      if ((payload['status'] ?? '') != 'OK') {
        return null;
      }

      final List<dynamic> results = payload['results'] is List
          ? payload['results'] as List<dynamic>
          : <dynamic>[];
      if (results.isEmpty) return null;

      final Map<String, dynamic> first = _asMap(results.first);
      final Map<String, dynamic> geometry = _asMap(first['geometry']);
      final Map<String, dynamic> location = _asMap(geometry['location']);

      final double lat = _toDouble(location['lat']);
      final double lng = _toDouble(location['lng']);
      if (lat == 0 && lng == 0) return null;

      return MapPlaceResultModel(
        name: (first['name'] ?? query).toString(),
        formattedAddress: (first['formatted_address'] ?? query).toString(),
        position: LatLng(lat, lng),
      );
    } catch (_) {
      return null;
    }
  }

  Future<MapPlaceResultModel?> _searchByGeocoding(String query) async {
    try {
      final Response<dynamic> response = await _dio.get(
        '$_mapsBase/geocode/json',
        queryParameters: <String, dynamic>{
          'address': query,
          'key': _mapsApiKey,
        },
      );

      final Map<String, dynamic> payload = _asMap(response.data);
      if ((payload['status'] ?? '') != 'OK') {
        return null;
      }

      final List<dynamic> results = payload['results'] is List
          ? payload['results'] as List<dynamic>
          : <dynamic>[];
      if (results.isEmpty) return null;

      final Map<String, dynamic> first = _asMap(results.first);
      final Map<String, dynamic> geometry = _asMap(first['geometry']);
      final Map<String, dynamic> location = _asMap(geometry['location']);

      final double lat = _toDouble(location['lat']);
      final double lng = _toDouble(location['lng']);
      if (lat == 0 && lng == 0) return null;

      return MapPlaceResultModel(
        name: (first['formatted_address'] ?? query).toString(),
        formattedAddress: (first['formatted_address'] ?? query).toString(),
        position: LatLng(lat, lng),
      );
    } catch (_) {
      return null;
    }
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
