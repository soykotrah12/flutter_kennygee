import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRouteModel {
  const MapRouteModel({
    required this.points,
    required this.distanceKm,
    required this.carMinutes,
    required this.walkMinutes,
    required this.bikeMinutes,
  });

  final List<LatLng> points;
  final double distanceKm;
  final int carMinutes;
  final int walkMinutes;
  final int bikeMinutes;

  String get carLabel => '$carMinutes min';
  String get walkLabel => '$walkMinutes min';
  String get bikeLabel => '$bikeMinutes min';
}
