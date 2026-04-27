class MenuApiResponse<T> {
  const MenuApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MenuApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Map<String, dynamic>)? dataParser,
  }) {
    return MenuApiResponse<T>(
      success: (json['success'] ?? false) as bool,
      message: (json['message'] ?? '').toString(),
      data: json['data'] != null && dataParser != null
          ? dataParser(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final String message;
  final T? data;
}
