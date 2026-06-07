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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.todaysProgress.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 10,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                ),
              ),
            ).animate().fadeIn(duration: 450.ms).scale(duration: 350.ms, curve: Curves.easeOut),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedCount/$totalCount ${AppStrings.tasksDone}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                Text(
                  '${(completionRate * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(duration: 400.ms);
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiary,
            colorScheme.tertiary.withValues(alpha: 0.8),
            colorScheme.secondary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.tertiary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: Colors.white, size: 20),
                const SizedBox(width: AppSizes.sm),
                Text(
                  AppStrings.thisMonthsSpend.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
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
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(width: AppSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trend ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (trend ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withValues(alpha: 0.45),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        trend ? Icons.trending_down : Icons.trending_up,
                        color: trend ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        trend ? 'Savings' : 'Overspend',
                        style: TextStyle(
                          color: trend ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 400.ms, delay: 200.ms, curve: Curves.easeOutBack),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${AppStrings.vsLastMonth}: ${lastSpend.toCurrency()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic).fadeIn(duration: 400.ms);
  }
}
