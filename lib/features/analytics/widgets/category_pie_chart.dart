import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../providers/analytics_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_skeleton.dart';

/// Pie chart for category breakdown.
class CategoryPieChart extends ConsumerWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(currentMonthCategoryTotalsProvider);

    return totalsAsync.when(
      loading: () => const LoadingSkeleton(height: 200),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (totals) {
        if (totals.isEmpty) {
          return const EmptyState(message: AppStrings.noExpensesMonth);
        }
        final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
        return SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: totals.entries.map((entry) {
                final pct = entry.value / grandTotal;
                return PieChartSectionData(
                  value: entry.value,
                  title: '${(pct * 100).toStringAsFixed(0)}%',
                  color: entry.key.color,
                  radius: 80,
                  titleStyle: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
