import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/providers.dart';
import '../../../core/storage/providers.dart';
import '../../auth/state/auth_controller.dart';
import '../data/chat_api.dart';
import '../domain/chat_message.dart';
import '../domain/chat_thread.dart';
import '../state/chat_state.dart';

final chatApiProvider = Provider<ChatApi>((ref) => ChatApi(ref.read(apiClientProvider)));

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

final chatHasHistoryProvider = Provider<bool>((ref) {
  final session = ref.watch(authControllerProvider);
  if (session == null) return false;

  final box = ref.watch(chatBoxProvider);
  final raw = box.get(ChatController.threadsKeyForUser(session.userId));
  if (raw == null || raw.isEmpty) {
    final legacyRaw = box.get(ChatController._legacyHistoryKey);
    if (legacyRaw == null || legacyRaw.isEmpty) return false;
    try {
      final list = jsonDecode(legacyRaw);
      return list is List && list.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  try {
    final decoded = jsonDecode(raw);
    return decoded is List && decoded.isNotEmpty;
  } catch (_) {
    return false;
  }
});

final chatThreadsProvider = Provider<List<ChatThread>>((ref) {
  final session = ref.watch(authControllerProvider);
  if (session == null) return const [];

  final box = ref.watch(chatBoxProvider);
  final raw = box.get(ChatController.threadsKeyForUser(session.userId));
  if (raw == null || raw.isEmpty) return const [];

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(ChatThread.fromJson)
        .where((t) => t.id.isNotEmpty)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  } catch (_) {
    return const [];
  }
});

class ChatController extends Notifier<ChatState> {
  static const _legacyHistoryKey = 'history';

  static String threadsKeyForUser(String userIdOrEmail) =>
      'threads:${userIdOrEmail.trim().toLowerCase()}';

  static String currentThreadKeyForUser(String userIdOrEmail) =>
      'currentThread:${userIdOrEmail.trim().toLowerCase()}';

  static String threadMessagesKeyForUser(String userIdOrEmail, String threadId) =>
      'thread:${userIdOrEmail.trim().toLowerCase()}:$threadId';

  static String migratedKeyForUser(String userIdOrEmail) =>
      'migrated:${userIdOrEmail.trim().toLowerCase()}';

  @override
  ChatState build() {
    final session = ref.watch(authControllerProvider);
    if (session == null) {
      return const ChatState(threadId: null, messages: [], isSending: false);
    }

    final box = ref.watch(chatBoxProvider);
    _migrateLegacyIfNeeded(box: box, userId: session.userId);

    final threads = _loadThreads(box: box, userId: session.userId);
    final currentThreadId = box.get(currentThreadKeyForUser(session.userId));
    final resolvedThreadId = _resolveThreadId(
      threads: threads,
      currentThreadId: currentThreadId,
    );
    if (resolvedThreadId != null && resolvedThreadId != currentThreadId) {
      unawaited(box.put(currentThreadKeyForUser(session.userId), resolvedThreadId));
    }

    final raw = resolvedThreadId == null
        ? null
        : box.get(threadMessagesKeyForUser(session.userId, resolvedThreadId));

    final messages = raw == null
        ? <ChatMessage>[]
        : _decodeMessagesSafe(raw, box: box, key: threadMessagesKeyForUser(session.userId, resolvedThreadId!));
    return ChatState(threadId: resolvedThreadId, messages: messages, isSending: false);
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final session = ref.read(authControllerProvider);
    if (session == null) return;

    final threadId = state.threadId ?? await startNewThread();

    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: _id(),
      role: ChatRole.user,
      text: trimmed,
      createdAt: now,
    );

    state = state.copyWith(
      threadId: threadId,
      messages: [...state.messages, userMsg],
      isSending: true,
      showFallback: false,
      lastError: null,
    );
    await _persist(threadId: threadId);

    try {
      final api = ref.read(chatApiProvider);
      final answer = await api.answer(trimmed);

      final botMsg = ChatMessage(
        id: _id(),
        role: ChatRole.bot,
        text: answer.answer,
        createdAt: DateTime.now(),
        sources: answer.sources,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isSending: false,
        showFallback: answer.fallback,
      );
      await _persist(threadId: threadId);
    } catch (e) {
      final errMsg = ChatMessage(
        id: _id(),
        role: ChatRole.bot,
        text: 'Ошибка: не удалось получить ответ. Проверьте соединение с локальным сервером.',
        createdAt: DateTime.now(),
        isError: true,
      );
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        isSending: false,
        showFallback: true,
        lastError: e.toString(),
      );
      await _persist(threadId: threadId);
    }
  }

  Future<String> startNewThread() async {
    final session = ref.read(authControllerProvider);
    if (session == null) return '';

    final box = ref.read(chatBoxProvider);
    final threadId = _id();
    await box.put(currentThreadKeyForUser(session.userId), threadId);
    state = state.copyWith(threadId: threadId, messages: [], isSending: false, showFallback: false, lastError: null);
    return threadId;
  }

  Future<void> openThread(String threadId) async {
    final session = ref.read(authControllerProvider);
    if (session == null) return;

    final box = ref.read(chatBoxProvider);
    await box.put(currentThreadKeyForUser(session.userId), threadId);
    final raw = box.get(threadMessagesKeyForUser(session.userId, threadId));
    final messages = raw == null
        ? <ChatMessage>[]
        : _decodeMessagesSafe(raw, box: box, key: threadMessagesKeyForUser(session.userId, threadId));
    state = state.copyWith(threadId: threadId, messages: messages, isSending: false, showFallback: false, lastError: null);
  }

  Future<void> deleteThread(String threadId) async {
    final session = ref.read(authControllerProvider);
    if (session == null) return;

    final box = ref.read(chatBoxProvider);
    final threads = _loadThreads(box: box, userId: session.userId);
    final updated = threads.where((t) => t.id != threadId).toList();
    await _saveThreads(box: box, userId: session.userId, threads: updated);
    await box.delete(threadMessagesKeyForUser(session.userId, threadId));

    if (state.threadId == threadId) {
      await startNewThread();
    }
  }

  Future<void> clear() async {
    final session = ref.read(authControllerProvider);
    if (session == null) return;

    final threadId = state.threadId;
    if (threadId != null) {
      await deleteThread(threadId);
      return;
    }
    state = const ChatState(threadId: null, messages: [], isSending: false);
  }

  Future<void> _persist({required String threadId}) async {
    final session = ref.read(authControllerProvider);
    if (session == null) return;

    final box = ref.read(chatBoxProvider);
    final messagesKey = threadMessagesKeyForUser(session.userId, threadId);
    final rawMessages = jsonEncode(state.messages.map((m) => m.toJson()).toList());
    await box.put(messagesKey, rawMessages);

    final now = DateTime.now();
    final threads = _loadThreads(box: box, userId: session.userId);
    final existingIndex = threads.indexWhere((t) => t.id == threadId);
    final title = _deriveTitle(state.messages);

    final createdAt = existingIndex == -1 ? now : threads[existingIndex].createdAt;
    final updatedThread = ChatThread(
      id: threadId,
      title: title,
      createdAt: createdAt,
      updatedAt: now,
    );

    final updatedThreads = [...threads];
    if (existingIndex == -1) {
      updatedThreads.add(updatedThread);
    } else {
      updatedThreads[existingIndex] = updatedThread;
    }
    await _saveThreads(box: box, userId: session.userId, threads: updatedThreads);
    await box.put(currentThreadKeyForUser(session.userId), threadId);
  }

  List<ChatMessage> _decodeMessagesSafe(
    String raw, {
    required Box<String> box,
    required String key,
  }) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <ChatMessage>[];

      final list = decoded.whereType<Map>().toList();
      return list
          .map((e) => Map<String, dynamic>.from(e))
          .map(ChatMessage.fromJson)
          .toList();
    } catch (_) {
      // Если история повреждена — не падаем и сбрасываем ключ.
      unawaited(box.delete(key));
      return const <ChatMessage>[];
    }
  }

  void _migrateLegacyIfNeeded({required Box<String> box, required String userId}) {
    final migratedKey = migratedKeyForUser(userId);
    if (box.get(migratedKey) == '1') return;

    final threadsRaw = box.get(threadsKeyForUser(userId));
    if (threadsRaw != null && threadsRaw.isNotEmpty) {
      unawaited(box.put(migratedKey, '1'));
      return;
    }

    final legacyRaw = box.get(_legacyHistoryKey);
    if (legacyRaw == null || legacyRaw.isEmpty) {
      unawaited(box.put(migratedKey, '1'));
      return;
    }

    final messages = _decodeMessagesSafe(
      legacyRaw,
      box: box,
      key: _legacyHistoryKey,
    );
    if (messages.isEmpty) {
      unawaited(box.put(migratedKey, '1'));
      return;
    }

    final threadId = _id();
    final messagesKey = threadMessagesKeyForUser(userId, threadId);
    unawaited(box.put(messagesKey, legacyRaw));
    unawaited(box.put(currentThreadKeyForUser(userId), threadId));

    final createdAt = messages.first.createdAt;
    final updatedAt = messages.last.createdAt;
    final thread = ChatThread(
      id: threadId,
      title: _deriveTitle(messages),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final raw = jsonEncode([thread.toJson()]);
    unawaited(box.put(threadsKeyForUser(userId), raw));
    unawaited(box.put(migratedKey, '1'));
  }

  List<ChatThread> _loadThreads({required Box<String> box, required String userId}) {
    final raw = box.get(threadsKeyForUser(userId));
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(ChatThread.fromJson)
          .where((t) => t.id.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveThreads({
    required Box<String> box,
    required String userId,
    required List<ChatThread> threads,
  }) async {
    final raw = jsonEncode(threads.map((t) => t.toJson()).toList());
    await box.put(threadsKeyForUser(userId), raw);
  }

  String? _resolveThreadId({
    required List<ChatThread> threads,
    required String? currentThreadId,
  }) {
    if (currentThreadId != null && currentThreadId.isNotEmpty) return currentThreadId;
    if (threads.isEmpty) return null;
    final sorted = [...threads]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.first.id;
  }

  String _deriveTitle(List<ChatMessage> messages) {
    final userMessages = messages.where((m) => m.role == ChatRole.user).toList();
    final raw = userMessages.isEmpty ? '' : userMessages.first.text.trim();
    if (raw.isEmpty) return 'Диалог';
    const maxLen = 48;
    return raw.length <= maxLen ? raw : '${raw.substring(0, maxLen)}…';
  }

  String _id() => '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9999)}';
}
