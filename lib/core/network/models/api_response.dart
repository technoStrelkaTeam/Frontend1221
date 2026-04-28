class ApiResponse<T> {
  const ApiResponse({
    required this.data,
    this.message,
    this.success = true,
  });

  final T data;
  final String? message;
  final bool success;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    var data = json['data'] ?? json['user'] ?? json['user_data'];
    if (data is Map<String, dynamic>) {
      return ApiResponse<T>(
        data: fromJsonT(data),
        message: json['message'] as String?,
        success: json['success'] as bool? ?? true,
      );
    }
    if (data is List) {
      return ApiResponse<T>(
        data: data is List<Map<String, dynamic>>
            ? fromJsonT({'items': data})
            : data as T,
        message: json['message'] as String?,
        success: json['success'] as bool? ?? true,
      );
    }
    throw FormatException('Unexpected data format: $data');
  }
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    this.hasNext,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final bool? hasNext;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items = json['items'] as List? ?? json['data'] as List? ?? [];
    return PaginatedResponse<T>(
      items: items
          .whereType<Map>()
          .map((e) => fromJsonT(Map<String, dynamic>.from(e)))
          .toList(),
      total: json['total'] as int? ?? items.length,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? items.length,
      hasNext: json['hasNext'] as bool?,
    );
  }
}
