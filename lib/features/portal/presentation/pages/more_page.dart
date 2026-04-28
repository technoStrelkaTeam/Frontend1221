import 'package:flutter/material.dart';

import '../../../../core/ui/responsive.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Документы'),
            subtitle: Text('Справки, приказы, шаблоны.'),
          ),
          ListTile(
            leading: Icon(Icons.newspaper_outlined),
            title: Text('Новости компании'),
            subtitle: Text('Лента новостей/объявлений.'),
          ),
          ListTile(
            leading: Icon(Icons.assignment_outlined),
            title: Text('Заявки'),
            subtitle: Text('Заявка на справку, пропуск, техника.'),
          ),
        ],
      ),
    );
  }
}

