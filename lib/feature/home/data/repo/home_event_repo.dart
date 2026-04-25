import 'package:intl/intl.dart';

import '../../../../core/common/constants/app_images.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/constants/api_constants.dart';
import '../../../../core/network/network_result.dart';
import '../model/event_api_model.dart';
import '../model/event_going_status_model.dart';
import '../model/event_model.dart';

class HomeEventRepository {
  HomeEventRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  NetworkResult<List<EventModel>> fetchEvents() {
    return _apiClient.get<List<EventModel>>(
      ApiConstants.event.fetchEvents,
      fromJsonT: (json) {
        final List<dynamic> raw = json is List ? json : <dynamic>[];

        return raw
            .map((item) => EventApiModel.fromJson(_asMap(item)))
            .map(_toEventModel)
            .toList();
      },
    );
  }

  NetworkResult<EventModel> fetchEventDetails(String eventId) {
    return _apiClient.get<EventModel>(
      ApiConstants.event.fetchEventById(eventId),
      fromJsonT: (json) {
        final EventApiModel raw = EventApiModel.fromJson(_asMap(json));
        return _toEventModel(raw);
      },
    );
  }

  NetworkResult<EventGoingStatusModel> fetchGoingStatus(String eventId) {
    return _apiClient.get<EventGoingStatusModel>(
      ApiConstants.event.fetchGoingStatus(eventId),
      fromJsonT: (json) => EventGoingStatusModel.fromJson(_asMap(json)),
    );
  }

  NetworkResult<EventGoingStatusModel> toggleGoing(String eventId) {
    return _apiClient.patch<EventGoingStatusModel>(
      ApiConstants.event.toggleGoing(eventId),
      data: const <String, dynamic>{},
      fromJsonT: (json) => EventGoingStatusModel.fromJson(_asMap(json)),
    );
  }

  EventModel _toEventModel(EventApiModel event) {
    final String resolvedTitle = event.title.trim().isNotEmpty
        ? event.title.trim()
        : 'Event';
    final String resolvedDescription = event.description.trim().isNotEmpty
        ? event.description.trim()
        : 'No description available';

    final String resolvedLocation = _resolveLocation(
      shopName: event.shopName,
      shopAddress: event.shopAddress,
    );

    return EventModel(
      id: event.eventId,
      title: resolvedTitle,
      image: event.imageUrl.trim().isNotEmpty
          ? event.imageUrl.trim()
          : AppImages.homeRestaurant1,
      date: _formatDate(event.date),
      time: _formatTime(event.time),
      fee: _formatEntryFee(event.entryFee),
      location: resolvedLocation,
      detailsTitle: resolvedTitle,
      detailsDescription: resolvedDescription,
      actionLabel: 'I am Going',
      isGoing: event.isGoing,
    );
  }

  String _resolveLocation({
    required String shopName,
    required String shopAddress,
  }) {
    final String name = shopName.trim();
    final String address = shopAddress.trim();

    if (name.isNotEmpty && address.isNotEmpty) {
      return '$name, $address';
    }
    if (name.isNotEmpty) return name;
    if (address.isNotEmpty) return address;
    return 'Location TBA';
  }

  String _formatDate(String raw) {
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'DATE TBA';
    return DateFormat('EEE, MMM d').format(parsed).toUpperCase();
  }

  String _formatTime(String raw) {
    if (raw.trim().isEmpty) return 'Time TBA';

    DateTime? parsed;

    try {
      parsed = DateFormat('HH:mm').parseStrict(raw);
    } catch (_) {
      parsed = DateTime.tryParse(raw);
    }

    if (parsed == null) return raw;
    return DateFormat('h:mm a').format(parsed);
  }

  String _formatEntryFee(double fee) {
    if (fee <= 0) return 'Free';

    final bool isWhole = fee % 1 == 0;
    final String amount = isWhole
        ? fee.toStringAsFixed(0)
        : fee.toStringAsFixed(2);
    return '\$$amount';
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return <String, dynamic>{};
}
