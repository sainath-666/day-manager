import 'package:dailyflow/data/models/expense.dart';
import 'package:dailyflow/data/repositories/i_expense_repository.dart';
import 'package:dailyflow/data/models/monthly_total.dart';
import 'package:dailyflow/providers/analytics_providers.dart';
import 'package:dailyflow/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeExpenseRepository implements IExpenseRepository {
  @override
  Future<void> add(Expense expense) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Expense>> getAll() async => [];

  @override
  Future<List<Expense>> getByMonth(int year, int month) async => [];

  @override
  Future<Map<int, double>> getCategoryTotals(int year, int month) async =>
      {0: 450, 2: 850};

  @override
  Future<Expense?> getById(String id) async => null;

  @override
  Future<List<MonthlyTotal>> getMonthlyTotals(int months) async =>
      List.generate(months, (i) => MonthlyTotal(year: 2026, month: i + 1, total: 100));

  @override
  Future<void> update(Expense expense) async {}

  @override
  Stream<List<Expense>> watchAll() => Stream.value([]);
}

void main() {
  test('currentMonthCategoryTotalsProvider maps categories', () async {
    final container = ProviderContainer(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(FakeExpenseRepository()),
      ],
    );
    addTearDown(container.dispose);

    final totals = await container.read(currentMonthCategoryTotalsProvider.future);
    expect(totals.length, 2);
    expect(totals.values.fold<double>(0, (a, b) => a + b), 1300);
  });
}
