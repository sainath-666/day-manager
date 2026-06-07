import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/extensions/date_time_ext.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/date_time_picker_field.dart';
import 'widgets/expense_form.dart';
import 'widgets/expense_tile.dart';
import 'widgets/month_summary_card.dart';

/// Expenses list grouped by date with monthly summary.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: ExpenseForm(
          onSave: (expense) async {
            await ref.read(expensesNotifierProvider.notifier).add(expense);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = e.date.formatRelative();
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesNotifierProvider);
    final monthExpenses = ref.watch(monthExpensesProvider);
    final selectedMonth = ref.watch(selectedExpenseMonthProvider);
    final total = monthExpenses.fold<double>(0, (s, e) => s + e.amount);
    final grouped = _groupByDate(monthExpenses);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.expenses),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => context.push('/scan'),
            tooltip: AppStrings.scanBill,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/analytics'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(expensesNotifierProvider),
        ),
        data: (_) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: MonthSelector(
                selected: selectedMonth,
                onChanged: (m) =>
                    ref.read(selectedExpenseMonthProvider.notifier).state = m,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: MonthSummaryCard(total: total),
            ),
            Expanded(
              child: monthExpenses.isEmpty
                  ? const EmptyState(message: AppStrings.noExpenses)
                  : ListView(
                      children: grouped.entries.expand((entry) {
                        return [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              entry.key,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          ...entry.value.map((e) => ExpenseTile(expense: e)),
                        ];
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
