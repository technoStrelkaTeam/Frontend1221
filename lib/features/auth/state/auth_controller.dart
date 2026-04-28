import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/models/api_response.dart';
import '../../../core/storage/providers.dart';
import '../data/auth_repository.dart';
import '../domain/auth_session.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthSession?>(AuthController.new);

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider)?.token;
});

final authPasswordProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider)?.password;
});

class AuthController extends Notifier<AuthSession?> {
  static const _userIdKey = 'userId';
  static const _tokenKey = 'token';
  static const _passwordKey = 'password';
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
    final password = prefs.getString(_passwordKey);
    if (userId == null || token == null) return null;
    if (!userId.contains('@')) return null;
    final savedDisplayName = prefs.getString(_displayNameKey);
    return AuthSession(
      userId: userId,
      token: token,
      displayName: (savedDisplayName == null || savedDisplayName.trim().isEmpty)
          ? _displayNameForEmail(userId)
          : savedDisplayName.trim(),
      password: password,
    );
  }

  Future<ApiResponse<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      final user = response.user;
      final prefs = ref.read(sharedPreferencesProvider);
      final token = user.token ?? user.id;
      await prefs.setString(_userIdKey, user.email);
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_passwordKey, password);
      await prefs.setString(_displayNameKey, user.name);
      state = AuthSession(
        userId: user.email,
        token: token,
        displayName: user.name,
        password: password,
      );
      if (response.history.isNotEmpty) {
        await _importHistory(email: user.email, history: response.history);
      }
      return ApiResponse<void>(
        data: null,
        message: null,
        success: true,
      );
    } catch (e) {
      return ApiResponse<void>(
        data: null,
        message: 'Ошибка входа: $e',
        success: false,
      );
    }
  }

  Future<void> _importHistory({
    required String email,
    required List<String> history,
  }) async {
    final box = ref.read(chatBoxProvider);
    final threadId = '${DateTime.now().microsecondsSinceEpoch}_imported';
    final messages = <Map<String, dynamic>>[];
    for (var i = 0; i < history.length; i += 2) {
      if (i < history.length) {
        messages.add({
          'id': '${threadId}_$i',
          'role': 'user',
          'text': history[i],
          'createdAt': DateTime.now().toIso8601String(),
          'sources': <Map<String, dynamic>>[],
          'isError': false,
        });
      }
      if (i + 1 < history.length) {
        messages.add({
          'id': '${threadId}_${i + 1}',
          'role': 'bot',
          'text': history[i + 1],
          'createdAt': DateTime.now().toIso8601String(),
          'sources': <Map<String, dynamic>>[],
          'isError': false,
        });
      }
    }
    if (messages.isNotEmpty) {
      final threadKey = 'threads:${email.trim().toLowerCase()}';
      final threadsJson = box.get(threadKey);
      final threads = <Map<String, dynamic>>[];
      if (threadsJson != null && threadsJson.isNotEmpty) {
        final decoded = jsonDecode(threadsJson) as List;
        for (final item in decoded) {
          if (item is Map) {
            threads.add(Map<String, dynamic>.from(item));
          }
        }
      }
      threads.insert(0, {
        'id': threadId,
        'title': messages.first['text'],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      await box.put(threadKey, jsonEncode(threads));
      await box.put('thread:${email.trim().toLowerCase()}:$threadId', jsonEncode(messages));
      await box.put('currentThread:${email.trim().toLowerCase()}', threadId);
    }
  }

  Future<void> signOut() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_userIdKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_displayNameKey);
    state = null;
  }
}
