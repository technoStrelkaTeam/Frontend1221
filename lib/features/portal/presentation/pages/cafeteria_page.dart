import 'package:flutter/material.dart';

import '../../../../core/ui/responsive.dart';

class CafeteriaPage extends StatelessWidget {
  const CafeteriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: 900,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: const [
          ListTile(
            leading: Icon(Icons.account_balance_wallet_outlined),
            title: Text('Баланс кафетерия'),
            subtitle: Text('Заглушка: подключим после интеграции с бэкендом.'),
          ),
          ListTile(
            leading: Icon(Icons.receipt_long_outlined),
            title: Text('История покупок'),
            subtitle: Text('Заглушка: список транзакций.'),
          ),
        ],
      ),
    );
  }
}

