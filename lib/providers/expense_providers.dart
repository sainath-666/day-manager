import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/expense.dart';
import 'repository_providers.dart';

/// All expenses notifier.
class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() async {
    return ref.watch(expenseRepositoryProvider).getAll();
  }

  Future<void> add(Expense expense) async {
    await ref.read(expenseRepositoryProvider).add(expense);
    ref.invalidateSelf();
  }

  Future<void> updateExpense(Expense expense) async {
    await ref.read(expenseRepositoryProvider).update(expense);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(expenseRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(ExpensesNotifier.new);

/// Selected month for expense list view.
final selectedExpenseMonthProvider = StateProvider<DateTime>(
  (ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  },
);

/// Expenses for the selected month.
final monthExpensesProvider = Provider<List<Expense>>((ref) {
  final month = ref.watch(selectedExpenseMonthProvider);
  final allAsync = ref.watch(expensesNotifierProvider);
  return allAsync.when(
    data: (expenses) => expenses
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Total spend for current month.
final currentMonthSpendProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final allAsync = ref.watch(expensesNotifierProvider);
  return allAsync.when(
    data: (expenses) => expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0, (sum, e) => sum + e.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Total spend for previous month.
final lastMonthSpendProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final lastMonth = DateTime(now.year, now.month - 1);
  final allAsync = ref.watch(expensesNotifierProvider);
  return allAsync.when(
    data: (expenses) => expenses
        .where((e) =>
            e.date.year == lastMonth.year && e.date.month == lastMonth.month)
        .fold<double>(0, (sum, e) => sum + e.amount),
    loading: () => 0,
    error: (_, __) => 0,
  );
});
