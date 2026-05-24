import 'package:dio/dio.dart';

class OwnerMapGeocodeService {
  OwnerMapGeocodeService({Dio? dio}) : _dio = dio ?? Dio();

  static const String _mapsApiKey = 'AIzaSyClug6MI9bNV5pX50D6ugaFBi5TKTXCqIs';
  static const String _mapsBase = 'https://maps.googleapis.com/maps/api';

  final Dio _dio;

  Future<String?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get(
        '$_mapsBase/geocode/json',
        queryParameters: <String, dynamic>{
          'latlng': '$latitude,$longitude',
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
      if (results.isEmpty) {
        return null;
      }

      final Map<String, dynamic> first = _asMap(results.first);
      final String address = (first['formatted_address'] ?? '').toString();
      return address.trim().isEmpty ? null : address;
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
