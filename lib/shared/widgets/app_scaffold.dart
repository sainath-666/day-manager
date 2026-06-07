import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
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
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 104),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slide = Tween<Offset>(
                    begin: const Offset(0.04, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(index),
                  child: child,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSizes.md,
            right: AppSizes.md,
            bottom: AppSizes.md,
            child: SafeArea(
              minimum: EdgeInsets.zero,
              child: _PillNavigationBar(
                selectedIndex: index,
                onTap: (i) => _onTap(context, i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillNavigationBar extends StatelessWidget {
  const _PillNavigationBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _PillNavData(
      label: AppStrings.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _PillNavData(
      label: AppStrings.tasks,
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
    ),
    _PillNavData(
      label: AppStrings.schedule,
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
    ),
    _PillNavData(
      label: AppStrings.expenses,
      icon: Icons.payments_outlined,
      selectedIcon: Icons.payments,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.sm),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                flex: selectedIndex == i ? 5 : 1,
                child: _PillNavItem(
                  data: _items[i],
                  selected: selectedIndex == i,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PillNavItem extends StatelessWidget {
  const _PillNavItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _PillNavData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? Colors.white : colorScheme.onSurfaceVariant;

    return Semantics(
      selected: selected,
      button: true,
      label: data.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 52,
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 12 : 4,
          ),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: Icon(
                  selected ? data.selectedIcon : data.icon,
                  color: foreground,
                  size: 22,
                ),
              ),
              if (selected)
                Flexible(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 6),
                    child: Text(
                      data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillNavData {
  const _PillNavData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
