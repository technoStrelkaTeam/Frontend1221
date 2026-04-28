// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../../chat/state/chat_controller.dart';

class PortalScaffold extends ConsumerWidget {
  const PortalScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  bool _isSelected(String path) =>
      location == path || (path != '/portal/home' && location.startsWith(path));

  String _title() {
    if (location.startsWith('/portal/chat/history')) return 'История';
    if (location.startsWith('/portal/chat')) return 'Чат';
    if (location.startsWith('/portal/contacts')) return 'Контакты';
    if (location.startsWith('/portal/documents')) return 'Документы';
    if (location.startsWith('/portal/cafeteria')) return 'Кафетерий';
    if (location.startsWith('/portal/benefits')) return 'Льготы';
    if (location.startsWith('/portal/more')) return 'Для сотрудников';
    if (location.startsWith('/portal/settings')) return 'Настройки';
    return 'HR Assistant';
  }

  List<Widget> _actions(BuildContext context, WidgetRef ref) {
    if (location.startsWith('/portal/chat')) {
      return [
        IconButton(
          tooltip: 'История',
          onPressed: () => context.push('/portal/chat/history'),
          icon: const Icon(Icons.history),
        ),
        IconButton(
          tooltip: 'Новый разговор',
          onPressed: () async {
            await ref.read(chatControllerProvider.notifier).startNewThread();
            if (!context.mounted) return;
            context.go('/portal/chat');
          },
          icon: const Icon(Icons.add_comment_outlined),
        ),
      ];
    }
    return const [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_title()),
        actions: _actions(context, ref),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Builder(builder: (context) {
                final scheme = Theme.of(context).colorScheme;
                final isDark = scheme.brightness == Brightness.dark;
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: isDark
                        ? scheme.surfaceContainerHighest
                        : scheme.primaryContainer,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: isDark
                        ? scheme.primary.withOpacity(0.2)
                        : scheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person_outline,
                      color: scheme.primary,
                    ),
                  ),
                  accountName: Text(
                    session?.displayName ?? 'Сотрудник',
                    style: TextStyle(
                      color: isDark
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  accountEmail: Text(
                    session?.userId ?? '',
                    style: TextStyle(
                      color: isDark
                          ? scheme.onSurfaceVariant.withOpacity(0.7)
                          : scheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                );
              }),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      selected: _isSelected('/portal/home'),
                      leading: const Icon(Icons.home_outlined),
                      title: const Text('Главная'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/home');
                      },
                    ),
                    ListTile(
                      selected: _isSelected('/portal/chat'),
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: const Text('Чат'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/chat');
                      },
                    ),
                    ListTile(
                      selected: _isSelected('/portal/contacts'),
                      leading: const Icon(Icons.contacts_outlined),
                      title: const Text('Контакты'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/contacts');
                      },
                    ),
                    ListTile(
                      selected: _isSelected('/portal/cafeteria'),
                      leading: const Icon(Icons.local_cafe_outlined),
                      title: const Text('Кафетерий'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/cafeteria');
                      },
                    ),
                    ListTile(
                      selected: _isSelected('/portal/benefits'),
                      leading: const Icon(Icons.card_giftcard_outlined),
                      title: const Text('Льготы'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/benefits');
                      },
                    ),
                    ListTile(
                      selected: _isSelected('/portal/more'),
                      leading: const Icon(Icons.apps_outlined),
                      title: const Text('Для сотрудников'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/more');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      selected: _isSelected('/portal/settings'),
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Настройки'),
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/portal/settings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Выйти'),
                      onTap: session == null
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await ref.read(authControllerProvider.notifier).signOut();
                              if (!context.mounted) return;
                              context.go('/login');
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(child: child),
    );
  }
}
