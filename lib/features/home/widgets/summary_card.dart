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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.todaysProgress,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            LinearProgressIndicator(
              value: completionRate,
              minHeight: 10,
              color: colorScheme.primary,
              backgroundColor: colorScheme.onPrimaryContainer.withValues(
                alpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(999),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSizes.md),
            Text(
              '$completedCount/$totalCount ${AppStrings.tasksDone}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: colorScheme.onSecondaryContainer),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.thisMonthsSpend,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Text(
                  currentSpend.toCurrency(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: AppSizes.sm),
                Icon(
                  trend ? Icons.trending_down : Icons.trending_up,
                  color: trend
                      ? colorScheme.primary
                      : colorScheme.error,
                ),
              ],
            ),
            Text(
              '${AppStrings.vsLastMonth}: ${lastSpend.toCurrency()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.78,
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
