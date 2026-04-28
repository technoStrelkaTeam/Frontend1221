import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FormattedChatText extends StatelessWidget {
  const FormattedChatText({
    super.key,
    required this.text,
    this.onLinkTap,
  });

  final String text;
  final void Function(String url)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasMarkdown = _detectMarkdown(text);

    if (!hasMarkdown) {
      return SelectableText(text);
    }

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: theme.textTheme.bodyMedium,
        h1: theme.textTheme.headlineMedium,
        h2: theme.textTheme.headlineSmall,
        h3: theme.textTheme.titleLarge,
        strong: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        em: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        blockquotePadding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ),
        ),
        code: TextStyle(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockPadding: const EdgeInsets.all(12),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        listBullet: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null && onLinkTap != null) {
          onLinkTap!(href);
        }
      },
    );
  }

  bool _detectMarkdown(String text) {
    if (text.contains('**')) return true;
    if (text.contains('* ') && text.contains('\n')) return true;
    if (text.contains('```')) return true;
    if (RegExp(r'^\s*[-*+]\s', multiLine: true).hasMatch(text)) return true;
    if (RegExp(r'^\s*\d+\.\s', multiLine: true).hasMatch(text)) return true;
    if (text.contains('[') && text.contains('](')) return true;
    if (text.contains('> ')) return true;
    if (text.contains('# ')) return true;
    return false;
  }
}