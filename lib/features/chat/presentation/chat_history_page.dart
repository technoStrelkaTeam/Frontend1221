import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../domain/chat_thread.dart';
import '../state/chat_controller.dart';

class ChatHistoryPage extends ConsumerWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    final threads = ref.watch(chatThreadsProvider);

    if (session == null) {
      return const Center(child: Text('Сначала войдите в приложение.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(chatThreadsProvider);
      },
      child: threads.isEmpty
          ? ListView(
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text('История пустая.'),
                  ),
                ),
              ],
            )
          : ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => _ThreadTile(thread: threads[i]),
            ),
    );
  }
}

class _ThreadTile extends ConsumerWidget {
  const _ThreadTile({required this.thread});

  final ChatThread thread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline),
      title: Text(thread.title.isEmpty ? 'Диалог' : thread.title),
      subtitle: Text(_formatDateTime(context, thread.updatedAt)),
      onTap: () async {
        await ref.read(chatControllerProvider.notifier).openThread(thread.id);
        if (!context.mounted) return;
        context.replace('/portal/chat');
      },
      trailing: IconButton(
        tooltip: 'Удалить',
        icon: const Icon(Icons.delete_outline),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Удалить диалог?'),
              content: const Text('Диалог будет удалён без возможности восстановления.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Отмена'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Удалить'),
                ),
              ],
            ),
          );
          if (ok != true) return;
          await ref.read(chatControllerProvider.notifier).deleteThread(thread.id);
        },
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dt) {
    final ml = MaterialLocalizations.of(context);
    final local = dt.toLocal();
    final date = ml.formatShortDate(local);
    final time = ml.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: true,
    );
    return '$date $time';
  }
}
