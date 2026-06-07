import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/double_ext.dart';

/// Dashboard progress summary card.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.completionRate,
    required this.completedCount,
    required this.totalCount,
  });

  final double completionRate;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.todaysProgress,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            LinearProgressIndicator(
              value: completionRate,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSizes.sm),
            Text('$completedCount/$totalCount ${AppStrings.tasksDone}'),
          ],
        ),
      ),
    );
  }
}

/// Monthly spend summary card.
class SpendSummaryCard extends StatelessWidget {
  const SpendSummaryCard({
    super.key,
    required this.currentSpend,
    required this.lastSpend,
  });

  final double currentSpend;
  final double lastSpend;

  @override
  Widget build(BuildContext context) {
    final trend = currentSpend <= lastSpend;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.thisMonthsSpend,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Text(
                  currentSpend.toCurrency(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: AppSizes.sm),
                Icon(
                  trend ? Icons.trending_down : Icons.trending_up,
                  color: trend
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            Text(
              '${AppStrings.vsLastMonth}: ${lastSpend.toCurrency()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
