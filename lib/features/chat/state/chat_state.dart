import '../domain/chat_message.dart';

class ChatState {
  const ChatState({
    required this.threadId,
    required this.messages,
    required this.isSending,
    this.showFallback = false,
    this.lastError,
  });

  final String? threadId;
  final List<ChatMessage> messages;
  final bool isSending;
  final bool showFallback;
  final String? lastError;

  ChatState copyWith({
    String? threadId,
    List<ChatMessage>? messages,
    bool? isSending,
    bool? showFallback,
    String? lastError,
  }) {
    return ChatState(
      threadId: threadId ?? this.threadId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      showFallback: showFallback ?? this.showFallback,
      lastError: lastError,
    );
  }
}
