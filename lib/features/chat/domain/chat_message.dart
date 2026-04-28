import 'chat_source.dart';
import 'personal_data.dart';

enum ChatRole { user, bot }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.sources = const [],
    this.isError = false,
    this.personalData,
    this.base,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime createdAt;
  final List<ChatSource> sources;
  final bool isError;
  final PersonalDataPayload? personalData;
  final String? base;

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'sources': sources.map((s) => s.toJson()).toList(),
        'isError': isError,
        if (personalData != null) 'personal_data': personalData!.toJson(),
        if (base != null) 'base': base,
      };

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
        id: (json['id'] as String?) ?? '',
        role: _roleFromRaw(json['role'] as String?),
        text: (json['text'] as String?) ?? '',
        createdAt: DateTime.tryParse((json['createdAt'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        sources: ((json['sources'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .map(ChatSource.fromJson)
            .toList(),
        isError: (json['isError'] as bool?) ?? false,
        personalData: json['personal_data'] != null
            ? PersonalDataPayload.fromJson(
                Map<String, dynamic>.from(json['personal_data'] as Map))
            : null,
        base: json['base'] as String?,
      );

  static ChatRole _roleFromRaw(String? raw) {
    for (final r in ChatRole.values) {
      if (r.name == raw) return r;
    }
    return ChatRole.bot;
  }
}
