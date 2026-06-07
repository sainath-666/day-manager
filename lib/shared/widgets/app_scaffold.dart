import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';

/// Shell scaffold with bottom navigation and optional nav rail on wide screens.
class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/expenses') || location.startsWith('/scan')) {
      return 3;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/tasks');
      case 2:
        context.go('/schedule');
      case 3:
        context.go('/expenses');
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => _onTap(context, i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text(AppStrings.home),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle),
                  label: Text(AppStrings.tasks),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: Text(AppStrings.schedule),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.payments_outlined),
                  selectedIcon: Icon(Icons.payments),
                  label: Text(AppStrings.expenses),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: AppStrings.tasks,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: AppStrings.schedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments),
            label: AppStrings.expenses,
          ),
        ],
      ),
    );
  }
}
