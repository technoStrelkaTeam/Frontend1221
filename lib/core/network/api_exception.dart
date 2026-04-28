import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.code,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Object? details;

  @override
  String toString() {
    final sc = statusCode == null ? '' : ' ($statusCode)';
    return 'ApiException$sc: $message';
  }

  static ApiException fromDio(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Превышено время ожидания ответа сервера.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Проблема с сертификатом сервера.';
        break;
      case DioExceptionType.connectionError:
        message = 'Нет соединения с сервером.';
        break;
      case DioExceptionType.cancel:
        message = 'Запрос отменён.';
        break;
      case DioExceptionType.badResponse:
        message = _messageFromBody(data) ?? 'Ошибка сервера.';
        break;
      case DioExceptionType.unknown:
        message = 'Неизвестная ошибка сети.';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      details: data,
    );
  }

  static String? _messageFromBody(Object? data) {
    if (data is Map) {
      final m = data['message'];
      if (m is String && m.trim().isNotEmpty) return m.trim();
      final err = data['error'];
      if (err is String && err.trim().isNotEmpty) return err.trim();
    }
    return null;
  }
}

