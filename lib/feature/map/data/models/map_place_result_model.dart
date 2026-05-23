import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPlaceResultModel {
  const MapPlaceResultModel({
    required this.name,
    required this.formattedAddress,
    required this.position,
  });

  final String name;
  final String formattedAddress;
  final LatLng position;
}
