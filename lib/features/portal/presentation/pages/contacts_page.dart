import 'package:flutter/material.dart';

import '../../../../core/ui/responsive.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          _ContactTile(title: 'HR общий', subtitle: 'hr@company.ru • доб. 100'),
          _ContactTile(title: 'IT поддержка', subtitle: 'it@company.ru • доб. 200'),
          _ContactTile(title: 'Безопасность', subtitle: 'security@company.ru • доб. 300'),
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

