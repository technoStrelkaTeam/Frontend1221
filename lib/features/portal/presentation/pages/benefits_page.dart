import 'package:flutter/material.dart';

import '../../../../core/ui/responsive.dart';

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('ДМС'),
            subtitle: Text('Как подключить, документы, контакты страховой.'),
          ),
          ListTile(
            leading: Icon(Icons.school_outlined),
            title: Text('Обучение'),
            subtitle: Text('Компенсация курсов и развитие.'),
          ),
          ListTile(
            leading: Icon(Icons.fitness_center_outlined),
            title: Text('Спорт'),
            subtitle: Text('Абонементы и скидки.'),
          ),
        ],
      ),
    );
  }
}

