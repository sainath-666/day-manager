import 'package:dailyflow/data/models/expense.dart';
import 'package:dailyflow/data/repositories/hive_expense_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Expense> box;
  late HiveExpenseRepository repository;

  setUpAll(() async {
    Hive.init('./test_hive_expense');
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<Expense>(
      'expenses_test_${DateTime.now().microsecondsSinceEpoch}',
    );
    repository = HiveExpenseRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('getCategoryTotals returns correct sums', () async {
    final now = DateTime.now();
    await repository.add(Expense.create(
      amount: 100,
      category: 0,
      description: 'Food',
      date: now,
    ));
    await repository.add(Expense.create(
      amount: 200,
      category: 0,
      description: 'More food',
      date: now,
    ));
    await repository.add(Expense.create(
      amount: 50,
      category: 1,
      description: 'Fuel',
      date: now,
    ));

    final totals = await repository.getCategoryTotals(now.year, now.month);
    expect(totals[0], 300);
    expect(totals[1], 50);
  });

  test('getMonthlyTotals returns last N months', () async {
    final totals = await repository.getMonthlyTotals(6);
    expect(totals.length, 6);
  });
}
