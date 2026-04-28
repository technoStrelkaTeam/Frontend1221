import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../core/ui/responsive.dart';
import '../auth/state/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final theme = Theme.of(context);

    return ResponsiveCenter(
      maxWidth: 720,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: const Text('Пользователь'),
            subtitle: Text(session?.userId ?? 'Не авторизован'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Тема'),
            subtitle: Text(
              switch (themeMode) {
                ThemeMode.light => 'Светлая',
                ThemeMode.dark => 'Тёмная',
                ThemeMode.system => 'Системная',
              },
            ),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (v) {
                if (v == null) return;
                ref.read(themeModeControllerProvider.notifier).setMode(v);
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Системная')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Светлая')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Тёмная')),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: session == null
                ? null
                : () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
          const SizedBox(height: 12),
          Text(
            'Подсказка: для демо используйте вопросы про отпуск/ДМС/расчетный лист.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
