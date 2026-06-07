import '../models/expense.dart';
import '../models/monthly_total.dart';

/// Abstract expense repository interface.
abstract class IExpenseRepository {
  Future<List<Expense>> getAll();
  Future<List<Expense>> getByMonth(int year, int month);
  Future<Map<int, double>> getCategoryTotals(int year, int month);
  Future<List<MonthlyTotal>> getMonthlyTotals(int months);
  Future<Expense?> getById(String id);
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
  Stream<List<Expense>> watchAll();
}
