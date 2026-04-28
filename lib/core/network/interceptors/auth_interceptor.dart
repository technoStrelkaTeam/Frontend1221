import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_application_1/features/auth/state/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final userId = _ref.read(authTokenProvider);
    final password = _ref.read(authPasswordProvider);
    if (userId != null && userId.isNotEmpty && password != null && password.isNotEmpty) {
      final credentials = base64Encode(utf8.encode('$userId:$password'));
      options.headers['Authorization'] = 'Basic $credentials';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
    }
    super.onError(err, handler);
  }
}
