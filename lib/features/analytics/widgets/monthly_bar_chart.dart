import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/models/monthly_total.dart';
import '../../../providers/analytics_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_skeleton.dart';

/// Bar chart for month-over-month spending.
class MonthlyBarChart extends ConsumerWidget {
  const MonthlyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsAsync = ref.watch(lastSixMonthTotalsProvider);

    return totalsAsync.when(
      loading: () => const LoadingSkeleton(height: 200),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (totals) => _BarChartContent(totals: totals),
    );
  }
}

class _BarChartContent extends StatelessWidget {
  const _BarChartContent({required this.totals});

  final List<MonthlyTotal> totals;

  @override
  Widget build(BuildContext context) {
    final maxY = totals.fold<double>(0, (m, t) => t.total > m ? t.total : m);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          barGroups: List.generate(totals.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals[i].total,
                  color: Theme.of(context).colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= totals.length) return const SizedBox.shrink();
                  return Text(
                    DateFormat('MMM').format(
                      DateTime(totals[i].year, totals[i].month),
                    ),
                    style: Theme.of(context).textTheme.labelSmall,
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
