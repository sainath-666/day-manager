import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/app_animations.dart';

/// Expandable FAB for quick-add actions with smooth open/close animation.
class QuickAddFab extends StatefulWidget {
  const QuickAddFab({super.key});

  @override
  State<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends State<QuickAddFab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.enterCurve,
      reverseCurve: AppAnimations.exitCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _navigateAndClose(VoidCallback action) {
    _toggle();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizeTransition(
          sizeFactor: _expandAnimation,
          axisAlignment: -1,
          child: FadeTransition(
            opacity: _expandAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SubFab(
                  heroTag: 'add_task',
                  icon: Icons.task_alt,
                  label: 'New Task',
                  onPressed: () => _navigateAndClose(() => context.push('/tasks/new')),
                )
                    .animate()
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.3, end: 0, duration: 250.ms, curve: AppAnimations.bounceCurve),
                const SizedBox(height: 10),
                _SubFab(
                  heroTag: 'add_expense',
                  icon: Icons.receipt_long,
                  label: 'Scan Bill',
                  onPressed: () => _navigateAndClose(() => context.push('/scan')),
                )
                    .animate(delay: 40.ms)
                    .fadeIn(duration: 200.ms)
                    .slideY(begin: 0.3, end: 0, duration: 250.ms, curve: AppAnimations.bounceCurve),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          tooltip: AppStrings.addTask,
          child: AnimatedRotation(
            turns: _expanded ? 0.125 : 0,
            duration: AppAnimations.normal,
            curve: AppAnimations.bounceCurve,
            child: Icon(_expanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

class _SubFab extends StatelessWidget {
  const _SubFab({
    required this.heroTag,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String heroTag;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(
          heroTag: heroTag,
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }
}
