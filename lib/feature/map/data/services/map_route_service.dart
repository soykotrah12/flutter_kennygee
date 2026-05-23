import 'dart:math';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/map_route_model.dart';

class MapRouteService {
  MapRouteService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _mapsApiKey = 'AIzaSyClug6MI9bNV5pX50D6ugaFBi5TKTXCqIs';
  static const String _mapsBase = 'https://maps.googleapis.com/maps/api';

  final Dio _dio;

  Future<MapRouteModel?> buildWalkingRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get(
        '$_mapsBase/directions/json',
        queryParameters: <String, dynamic>{
          'origin': '${from.latitude},${from.longitude}',
          'destination': '${to.latitude},${to.longitude}',
          'mode': 'walking',
          'key': _mapsApiKey,
        },
      );

      final Map<String, dynamic> payload = _asMap(response.data);
      if ((payload['status'] ?? '') != 'OK') {
        return null;
      }

      final List<dynamic> routes = payload['routes'] is List
          ? payload['routes'] as List<dynamic>
          : <dynamic>[];
      if (routes.isEmpty) return null;

      final Map<String, dynamic> firstRoute = _asMap(routes.first);
      final String encodedPolyline =
          _asMap(firstRoute['overview_polyline'])['points']?.toString() ?? '';
      final List<LatLng> decodedPoints = _decodePolyline(encodedPolyline);

      final List<dynamic> legs = firstRoute['legs'] is List
          ? firstRoute['legs'] as List<dynamic>
          : <dynamic>[];

      int durationSeconds = 0;
      double distanceMeters = 0;

      for (final dynamic legRaw in legs) {
        final Map<String, dynamic> leg = _asMap(legRaw);
        durationSeconds += _toInt(_asMap(leg['duration'])['value']);
        distanceMeters += _toDouble(_asMap(leg['distance'])['value']);
      }

      if (distanceMeters <= 0) {
        distanceMeters = Geolocator.distanceBetween(
          from.latitude,
          from.longitude,
          to.latitude,
          to.longitude,
        );
      }

      final double distanceKm = distanceMeters / 1000;
      final int walkMinutes = max(
        1,
        durationSeconds > 0
            ? (durationSeconds / 60).round()
            : ((distanceKm / 4.8) * 60).round(),
      );
      final int carMinutes = max(1, ((distanceKm / 34) * 60).round());
      final int bikeMinutes = max(1, ((distanceKm / 15) * 60).round());

      return MapRouteModel(
        points: decodedPoints.isNotEmpty ? decodedPoints : <LatLng>[from, to],
        distanceKm: distanceKm,
        carMinutes: carMinutes,
        walkMinutes: walkMinutes,
        bikeMinutes: bikeMinutes,
      );
    } catch (_) {
      return null;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    if (encoded.isEmpty) return <LatLng>[];

    final List<LatLng> poly = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;

      while (true) {
        final int b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
        if (b < 0x20) break;
      }

      final int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      while (true) {
        final int b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
        if (b < 0x20) break;
      }

      final int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
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

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
