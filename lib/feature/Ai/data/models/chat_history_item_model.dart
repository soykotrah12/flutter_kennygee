class ChatHistoryItemModel {
  const ChatHistoryItemModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ChatHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['_id'] ?? json['id'];
    final dynamic rawTitle = json['title'];
    final dynamic rawCreatedAt = json['createdAt'];
    final dynamic rawUpdatedAt = json['updatedAt'];

    return ChatHistoryItemModel(
      id: rawId is String ? rawId : '',
      title: rawTitle is String && rawTitle.trim().isNotEmpty
          ? rawTitle
          : 'New Chat',
      createdAt: rawCreatedAt is String
          ? DateTime.tryParse(rawCreatedAt)
          : null,
      updatedAt: rawUpdatedAt is String
          ? DateTime.tryParse(rawUpdatedAt)
          : null,
    );
  }
}
