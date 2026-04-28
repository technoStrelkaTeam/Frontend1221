import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/models/api_response.dart';
import '../../../core/network/providers.dart';
import 'models/user_model.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthApi(api);
});

class AuthApi {
  const AuthApi(this._api);

  final ApiClient _api;

  Future<ApiResponse<UserModel>> register({
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final json = await _api.postJson<Object?>(
      '/users/add',
      data: {
        'email': email,
        'password': password,
        'role': role,
      },
    );
    if (json is Map<String, dynamic>) {
      return ApiResponse<UserModel>.fromJson(
        json,
        (data) => UserModel.fromJson(data),
      );
    }
    throw ApiException(message: 'Invalid response format');
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final credentials = base64Encode(utf8.encode('$email:$password'));
    final json = await _api.getJson<Object?>(
      '/users/login',
      options: Options(headers: {'Authorization': 'Basic $credentials'}),
    );
    if (json is Map<String, dynamic>) {
      return LoginResponse.fromJson(json);
    }
    throw ApiException(message: 'Invalid response format');
  }

  Future<String> ask(String message) async {
    final json = await _api.postJson<Object?>(
      '/users/answer',
      queryParameters: {'message': message},
    );
    if (json is Map<String, dynamic>) {
      return json['answer'] as String? ?? '';
    }
    if (json is String) {
      return json;
    }
    throw ApiException(message: 'Invalid response format');
  }

  Future<void> logout() async {
    await _api.postJson<Object?>('/users/logout');
  }
}

class LoginResponse {
  const LoginResponse({
    required this.user,
    required this.history,
  });

  final UserModel user;
  final List<String> history;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final userData = json['user_data'] as Map<String, dynamic>?;
    final historyList = (json['history'] as List?)?.cast<String>() ?? [];
    return LoginResponse(
      user: userData != null ? UserModel.fromJson(userData) : UserModel.fromJson(json),
      history: historyList,
    );
  }
}
