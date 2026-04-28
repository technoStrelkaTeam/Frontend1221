import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/chat_source.dart';

class ChatSourcesList extends StatelessWidget {
  const ChatSourcesList({super.key, required this.sources});

  final List<ChatSource> sources;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Основание:', style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        ...sources.map((s) {
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: s.url == null
                ? null
                : () async {
                    final uri = Uri.tryParse(s.url!);
                    if (uri == null) return;
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.article_outlined, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(s.ref, style: theme.textTheme.bodySmall),
                  ),
                  if (s.url != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new, size: 16),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

