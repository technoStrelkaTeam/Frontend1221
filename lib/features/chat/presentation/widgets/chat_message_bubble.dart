import 'package:flutter/material.dart';

import '../../domain/chat_message.dart';
import '../../domain/personal_data.dart';
import 'chat_sources_list.dart';
import 'personal_data_card.dart';
import 'formatted_chat_text.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == ChatRole.user;
    final bg = isUser ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest;
    final fg = isUser ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface;
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          elevation: 0,
          color: message.isError ? theme.colorScheme.errorContainer : bg,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(
                color: message.isError ? theme.colorScheme.onErrorContainer : fg,
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.personalData != null) ...[
                    _PersonalDataSection(data: message.personalData!),
                    const SizedBox(height: 12),
                    FormattedChatText(text: message.text),
                  ] else ...[
                    FormattedChatText(text: message.text),
                  ],
                  if (message.sources.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ChatSourcesList(sources: message.sources),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalDataSection extends StatelessWidget {
  const _PersonalDataSection({required this.data});

  final PersonalDataPayload data;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    if (data.vacationDays != null) {
      cards.add(PersonalDataCard(
        type: PersonalDataType.vacation,
        title: 'Остаток отпуска',
        value: '${data.vacationDays} дн.',
        subtitle: data.nextDate != null ? 'Ближайший отпуск: ${_formatDate(data.nextDate!)}' : null,
        date: data.nextDate,
      ));
    }

    if (data.salaryDate != null) {
      cards.add(PersonalDataCard(
        type: PersonalDataType.salaryAdvance,
        title: 'Дата выплаты',
        value: _formatDate(data.salaryDate!),
        subtitle: 'Аванс / зарплата',
        date: data.salaryDate,
      ));
    }

    if (data.dmsPrograms != null && data.dmsPrograms!.isNotEmpty) {
      cards.add(PersonalDataCard(
        type: PersonalDataType.dms,
        title: 'Программ�� ДМС',
        value: data.dmsPrograms!.length.toString(),
        subtitle: data.dmsPrograms!.join(', '),
      ));
    }

    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cards,
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

