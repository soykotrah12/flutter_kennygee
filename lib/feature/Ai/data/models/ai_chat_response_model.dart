class AiChatResponseModel {
  const AiChatResponseModel({required this.type, required this.data});

  final String type;
  final dynamic data;

  bool get isLocationRequest => type.toLowerCase() == 'location';
  bool get isRestaurantResponse => type.toLowerCase() == 'restaurants';

  String get textData => data is String ? (data as String).trim() : '';
  List<dynamic> get listData => data is List ? data as List<dynamic> : const [];

  factory AiChatResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawType = json['type'];
    final dynamic rawData = json['data'];

    return AiChatResponseModel(
      type: rawType is String ? rawType : '',
      data: rawData,
    );
  }
}
