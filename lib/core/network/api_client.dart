import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> getJson<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final res = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> postJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final res = await _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> putJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final res = await _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> deleteJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final res = await _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<T> patchJson<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final res = await _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return res.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<T>> getJsonList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final json = await getJson<Object?>(path, queryParameters: queryParameters);
    if (json is List) {
      return json.whereType<Map>().map((e) => fromJson(Map<String, dynamic>.from(e))).toList();
    }
    return const [];
  }

  Future<T> postJsonFor<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final json = await postJson<Object?>(path, data: data, queryParameters: queryParameters);
    if (json is Map<String, dynamic>) {
      return fromJson(json);
    }
    throw ApiException(message: 'Unexpected response format');
  }
}

