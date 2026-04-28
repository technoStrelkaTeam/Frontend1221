import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/responsive.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          const _ContactTile(title: 'HR общий', subtitle: 'hr@company.ru • доб. 100'),
          const _ContactTile(title: 'IT поддержка', subtitle: 'it@company.ru • доб. 200'),
          const _ContactTile(title: 'Безопасность', subtitle: 'security@company.ru • доб. 300'),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () => context.push('/portal/chat/ticket'),
              icon: const Icon(Icons.edit_note),
              label: const Text('Написать в HR'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.badge_outlined),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

