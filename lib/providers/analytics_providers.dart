import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/expense_category.dart';
import '../core/extensions/date_time_ext.dart';
import '../data/models/monthly_total.dart';
import '../core/enums/appointment_status.dart';
import 'appointment_providers.dart';
import 'repository_providers.dart';
import 'schedule_providers.dart';
import 'task_providers.dart';

/// Category totals for the current month.
final currentMonthCategoryTotalsProvider =
    FutureProvider<Map<ExpenseCategory, double>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final rawMap = await repo.getCategoryTotals(now.year, now.month);
  return rawMap.map(
    (key, value) => MapEntry(ExpenseCategory.fromInt(key), value),
  );
});

/// Last six months of expense totals.
final lastSixMonthTotalsProvider =
    FutureProvider<List<MonthlyTotal>>((ref) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getMonthlyTotals(6);
});

/// Top 3 spending categories for current month.
final topCategoriesProvider =
    FutureProvider<List<MapEntry<ExpenseCategory, double>>>((ref) async {
  final totals = await ref.watch(currentMonthCategoryTotalsProvider.future);
  final sorted = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(3).toList();
});

/// Upcoming reminder item for dashboard.
class UpcomingItem {
  const UpcomingItem({
    required this.title,
    required this.time,
    required this.type,
    this.priority = 0,
  });

  final String title;
  final String time;
  final String type;
  final int priority;
}

/// Next 3 upcoming tasks, schedule entries, and appointments combined.
final upcomingRemindersProvider = Provider<List<UpcomingItem>>((ref) {
  final todayTasks = ref.watch(todayTasksProvider);
  final scheduleAsync = ref.watch(scheduleNotifierProvider);
  final scheduleEntries = scheduleAsync.valueOrNull ?? [];
  final appointmentsAsync = ref.watch(appointmentsNotifierProvider);
  final appointments = appointmentsAsync.valueOrNull ?? [];

  final items = <UpcomingItem>[];

  for (final task in todayTasks.where((t) => !t.isCompleted)) {
    items.add(UpcomingItem(
      title: task.title,
      time: task.dueTime ?? '',
      type: 'task',
      priority: task.priority,
    ));
  }

  for (final entry in scheduleEntries.where((e) => e.date.isToday)) {
    items.add(UpcomingItem(
      title: entry.title,
      time: entry.startTime,
      type: 'schedule',
    ));
  }

  for (final appointment in appointments.where((a) {
    final status = AppointmentStatus.fromInt(a.status);
    return status.isActive && a.date.isToday;
  })) {
    items.add(UpcomingItem(
      title: appointment.title,
      time: appointment.time,
      type: 'appointment',
    ));
  }

  items.sort((a, b) => a.time.compareTo(b.time));
  return items.take(3).toList();
});
