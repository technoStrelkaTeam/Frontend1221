import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/models/api_response.dart';
import 'auth_api.dart';
import 'models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  return AuthRepository(api);
});

class AuthRepository {
  const AuthRepository(this._api);

  final AuthApi _api;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) =>
      _api.login(email: email, password: password);

  Future<ApiResponse<UserModel>> register({
    required String email,
    required String password,
    String role = 'user',
  }) =>
      _api.register(email: email, password: password, role: role);

  Future<void> logout() => _api.logout();

  Future<String> ask(String message) => _api.ask(message);
}
