import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/extensions/double_ext.dart';
import '../../providers/analytics_providers.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/stat_card.dart';

/// Analytics screen with charts and export.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  Future<void> _exportSummary(WidgetRef ref) async {
    final totals = await ref.read(currentMonthCategoryTotalsProvider.future);
    final monthly = await ref.read(lastSixMonthTotalsProvider.future);
    final buffer = StringBuffer('DailyFlow Expense Summary\n\n');
    buffer.writeln('Category Breakdown:');
    for (final entry in totals.entries) {
      buffer.writeln('  ${entry.key.label}: ${entry.value.toCurrency()}');
    }
    buffer.writeln('\nMonthly Totals:');
    for (final m in monthly) {
      buffer.writeln('  ${m.month}/${m.year}: ${m.total.toCurrency()}');
    }
    await Share.share(buffer.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topAsync = ref.watch(topCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.analytics)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AppStrings.categoryBreakdown,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const CategoryPieChart(),
          const SizedBox(height: 24),
          Text(AppStrings.monthOverMonth,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const MonthlyBarChart(),
          const SizedBox(height: 24),
          Text(AppStrings.topSpending,
              style: Theme.of(context).textTheme.titleMedium),
          topAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (top) => Column(
              children: List.generate(top.length, (i) {
                return StatCard(
                  rank: i + 1,
                  category: top[i].key,
                  amount: top[i].value,
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _exportSummary(ref),
            icon: const Icon(Icons.share),
            label: const Text(AppStrings.exportSummary),
          ),
        ],
      ),
    );
  }
}
