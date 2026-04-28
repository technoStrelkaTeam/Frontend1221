import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers.dart';
import '../domain/chat_source.dart';

final chatApiProvider = Provider<ChatApi>((ref) {
  final api = ref.watch(apiClientProvider);
  return ChatApi(api);
});

class ChatApi {
  const ChatApi(this._api);

  final ApiClient _api;

  Future<AnswerResponse> answer(String message) async {
    final response = await _api.postJson<Map<String, dynamic>>(
      '/users/answer',
      queryParameters: {'message': message},
    );
    
    final answer = response['answer'] as String? ?? '';
    final base = (response['base'] as String?)?.trim() ?? '';
    
    List<ChatSource> sources = [];
    
    if (base.isNotEmpty && !base.contains('не найден')) {
      String ref = base;
      String title = 'Основание';
      String? url;
      
      if (base.startsWith('Основание:')) {
        ref = base.substring(11).trim();
      }
      
      final urlMatch = RegExp(r'https?://[^\s]+').firstMatch(base);
      if (urlMatch != null) {
        url = urlMatch.group(0);
      } else {
        final docMatch = RegExp(r'([А-Я][а-я\s]+)(?:\.|$)').firstMatch(ref);
        if (docMatch != null) {
          final docName = docMatch.group(1)?.trim() ?? '';
          url = 'http://localhost:8000/documents/${Uri.encodeComponent(docName)}';
        }
      }
      
      sources.add(ChatSource(
        title: title,
        ref: ref,
        url: url,
      ));
    }
    
    final isFallback = answer.contains('не могу найти') || 
        answer.contains('свяжитесь с HR') ||
        base.contains('не найден');
    
    return AnswerResponse(
      answer: answer,
      sources: sources,
      fallback: isFallback,
    );
  }
}

class AnswerResponse {
  const AnswerResponse({
    required this.answer,
    required this.sources,
    this.fallback = false,
  });

  final String answer;
  final List<ChatSource> sources;
  final bool fallback;
}
