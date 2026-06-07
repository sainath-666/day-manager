import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../providers/analytics_providers.dart';
import 'category_chip.dart';

/// Monthly expense summary with top categories.
class MonthSummaryCard extends ConsumerWidget {
  const MonthSummaryCard({super.key, required this.total});

  final double total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topAsync = ref.watch(topCategoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${AppStrings.total}: ${total.toCurrency()}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            topAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (top) => Wrap(
                spacing: 8,
                children: top
                    .map((e) => CategoryChip(category: e.key, compact: true))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
