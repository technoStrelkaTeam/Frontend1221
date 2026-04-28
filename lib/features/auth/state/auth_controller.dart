import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/providers.dart';
import '../domain/auth_session.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthSession?>(AuthController.new);

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider)?.token;
});

class AuthController extends Notifier<AuthSession?> {
  static const _userIdKey = 'userId';
  static const _tokenKey = 'token';
  static const _displayNameKey = 'displayName';

  String _displayNameForEmail(String email) {
    final trimmed = email.trim();
    final at = trimmed.indexOf('@');
    if (at <= 0) return trimmed;

    final local = trimmed.substring(0, at);
    final parts = local.split(RegExp(r'[._-]+')).where((p) => p.isNotEmpty).toList();

    String titleCase(String s) {
      if (s.isEmpty) return s;
      final lower = s.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }

    if (parts.length >= 2) {
      final lastName = titleCase(parts[0]);
      final firstName = titleCase(parts[1]);
      return '$lastName $firstName';
    }

    return titleCase(local);
  }

  @override
  AuthSession? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final userId = prefs.getString(_userIdKey);
    final token = prefs.getString(_tokenKey);
    if (userId == null || token == null) return null;
    if (!userId.contains('@')) return null;
    final savedDisplayName = prefs.getString(_displayNameKey);
    return AuthSession(
      userId: userId,
      token: token,
      displayName: (savedDisplayName == null || savedDisplayName.trim().isEmpty)
          ? _displayNameForEmail(userId)
          : savedDisplayName.trim(),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final trimmedEmail = email.trim();
    final displayName = _displayNameForEmail(trimmedEmail);
    await prefs.setString(_userIdKey, trimmedEmail);
    await prefs.setString(_tokenKey, 'local-session-token');
    await prefs.setString(_displayNameKey, displayName);
    state = AuthSession(
      userId: trimmedEmail,
      token: 'local-session-token',
      displayName: displayName,
    );
  }

  Future<void> signOut() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_displayNameKey);
    state = null;
  }
}
