import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/welcome_page.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/chat/presentation/chat_history_page.dart';
import '../features/chat/presentation/hr_ticket_page.dart';
import '../features/portal/presentation/pages/benefits_page.dart';
import '../features/portal/presentation/pages/cafeteria_page.dart';
import '../features/portal/presentation/pages/contacts_page.dart';
import '../features/portal/presentation/pages/more_page.dart';
import '../features/portal/presentation/pages/portal_home_page.dart';
import '../features/portal/presentation/portal_scaffold.dart';
import '../features/settings/settings_page.dart';

final _routerRefreshNotifierProvider = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshNotifierProvider);

  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: '/',
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/welcome',
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/chat',
        redirect: (_, __) => '/portal/chat',
      ),
      GoRoute(
        path: '/chat/history',
        redirect: (_, __) => '/portal/chat/history',
      ),
      GoRoute(
        path: '/settings',
        redirect: (_, __) => '/portal/settings',
      ),
      ShellRoute(
        builder: (context, state, child) => PortalScaffold(
          location: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/portal',
            redirect: (_, __) => '/portal/home',
          ),
          GoRoute(
            path: '/portal/home',
            builder: (context, state) => const PortalHomePage(),
          ),
          GoRoute(
            path: '/portal/chat',
            builder: (context, state) => const ChatPage(),
            routes: [
              GoRoute(
                path: 'history',
                builder: (context, state) => const ChatHistoryPage(),
              ),
              GoRoute(
                path: 'ticket',
                builder: (context, state) {
                  final message = state.uri.queryParameters['message'];
                  return HrTicketPage(prefilledMessage: message);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/portal/contacts',
            builder: (context, state) => const ContactsPage(),
          ),
          GoRoute(
            path: '/portal/cafeteria',
            builder: (context, state) => const CafeteriaPage(),
          ),
          GoRoute(
            path: '/portal/benefits',
            builder: (context, state) => const BenefitsPage(),
          ),
          GoRoute(
            path: '/portal/more',
            builder: (context, state) => const MorePage(),
          ),
          GoRoute(
            path: '/portal/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final session = ref.read(authControllerProvider);
      final isLoggedIn = session != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggedIn && isLoggingIn) return '/portal';
      return null;
    },
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this.ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
