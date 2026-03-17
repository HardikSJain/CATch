import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/home/home_screen.dart';
import '../presentation/practice/practice_screen.dart';
import '../presentation/learn/concepts_screen.dart';
import '../presentation/learn/flashcard_screen.dart';
import '../presentation/stats/stats_screen.dart';
import '../presentation/settings/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/practice',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PracticeMenuScreen(),
          ),
        ),
        GoRoute(
          path: '/learn',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConceptsScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatsScreen(),
          ),
        ),
      ],
    ),
    // Full-screen routes (outside shell/bottom nav)
    GoRoute(
      path: '/practice/session',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'focused';
        final section = state.uri.queryParameters['section'];
        return PracticeScreen(mode: mode, section: section);
      },
    ),
    GoRoute(
      path: '/learn/review',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FlashcardScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

/// Shell widget with bottom navigation bar.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/practice')) return 1;
    if (location.startsWith('/learn')) return 2;
    if (location.startsWith('/stats')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFEEEEEE), width: 0.5),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          indicatorColor: Colors.black.withAlpha(15),
          elevation: 0,
          height: 64,
          selectedIndex: index,
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/home');
              case 1:
                context.go('/practice');
              case 2:
                context.go('/learn');
              case 3:
                context.go('/stats');
            }
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home, size: 22),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_outlined, size: 22),
              selectedIcon: Icon(Icons.edit, size: 22),
              label: 'Practice',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined, size: 22),
              selectedIcon: Icon(Icons.menu_book, size: 22),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, size: 22),
              selectedIcon: Icon(Icons.bar_chart, size: 22),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
