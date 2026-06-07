import 'package:hive/hive.dart';

import '../models/expense.dart';
import '../models/monthly_total.dart';
import 'i_expense_repository.dart';

/// Hive-backed expense repository with analytics helpers.
class HiveExpenseRepository implements IExpenseRepository {
  HiveExpenseRepository(this._box);

  final Box<Expense> _box;

  @override
  Future<List<Expense>> getAll() async {
    final expenses = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<List<Expense>> getByMonth(int year, int month) async =>
      _box.values
          .where((e) => e.date.year == year && e.date.month == month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Future<Map<int, double>> getCategoryTotals(int year, int month) async {
    final expenses = await getByMonth(year, month);
    final totals = <int, double>{};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  @override
  Future<List<MonthlyTotal>> getMonthlyTotals(int months) async {
    final now = DateTime.now();
    final results = <MonthlyTotal>[];

    for (var i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final year = date.year;
      final month = date.month;
      final monthExpenses = await getByMonth(year, month);
      final total = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
      results.add(MonthlyTotal(year: year, month: month, total: total));
    }
    return results;
  }

  @override
  Future<Expense?> getById(String id) async => _box.get(id);

  @override
  Future<void> add(Expense expense) async => _box.put(expense.id, expense);

  @override
  Future<void> update(Expense expense) async =>
      _box.put(expense.id, expense);

  @override
  Future<void> delete(String id) async => _box.delete(id);

  @override
  Stream<List<Expense>> watchAll() =>
      _box.watch().map((_) => _box.values.toList());
}
