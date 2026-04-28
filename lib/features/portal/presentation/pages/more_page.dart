import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/responsive.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Документы'),
            subtitle: const Text('Справки, приказы, шаблоны.'),
            onTap: () => context.go('/portal/documents'),
            trailing: const Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.newspaper_outlined),
            title: Text('Новости компании'),
            subtitle: Text('Лента новостей/объявлений.'),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: const Text('Заявки'),
            subtitle: const Text('Заявка на справку, пропуск, техника.'),
            onTap: () => context.go('/portal/chat/ticket'),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

