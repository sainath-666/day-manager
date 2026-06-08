import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/app_animations.dart';

/// Empty list placeholder with optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: colorScheme.primary),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.06, 1.06),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
                .animate()
                .fadeIn(duration: AppAnimations.normal)
                .slideY(begin: 0.1, end: 0, duration: AppAnimations.slow),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSizes.md),
              FilledButton.tonal(onPressed: onAction, child: Text(actionLabel!))
                  .animate()
                  .fadeIn(delay: 150.ms, duration: AppAnimations.normal)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    delay: 150.ms,
                    duration: AppAnimations.normal,
                    curve: AppAnimations.bounceCurve,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
