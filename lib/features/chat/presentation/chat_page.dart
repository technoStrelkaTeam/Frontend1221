import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/ui/responsive.dart';
import '../state/chat_controller.dart';
import 'widgets/chat_composer.dart';
import 'widgets/chat_message_bubble.dart';

class ChatPage extends HookConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatControllerProvider);

    return ResponsiveCenter(
      maxWidth: 900,
      child: Column(
        children: [
          Expanded(
            child: _MessagesList(),
          ),
          const SizedBox(height: 8),
          if (state.showFallback) const _FallbackCard(),
          ChatComposer(
            isSending: state.isSending,
            onSend: (text) => ref.read(chatControllerProvider.notifier).send(text),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MessagesList extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatControllerProvider);
    final controller = useScrollController();

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!controller.hasClients) return;
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
      return null;
    }, [state.messages.length, state.isSending]);

    if (state.messages.isEmpty) {
      return const Center(
        child: Text('Спросите, например: «Сколько дней отпуска осталось?»'),
      );
    }

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: state.messages.length + (state.isSending ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == state.messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final msg = state.messages[i];
        return ChatMessageBubble(message: msg);
      },
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.support_agent, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Не нашёл в документах? Нажмите «Написать в HR».'),
            ),
            const SizedBox(width: 12),
            FilledButton.tonal(
              onPressed: () => context.push('/portal/chat/ticket'),
              child: const Text('Написать в HR'),
            ),
          ],
        ),
      ),
    );
  }
}
