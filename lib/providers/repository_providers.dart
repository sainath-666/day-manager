import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/hive_appointment_repository.dart';
import '../data/repositories/hive_expense_repository.dart';
import '../data/repositories/hive_schedule_repository.dart';
import '../data/repositories/hive_task_repository.dart';
import '../data/repositories/i_appointment_repository.dart';
import '../data/repositories/i_expense_repository.dart';
import '../data/repositories/i_schedule_repository.dart';
import '../data/repositories/i_task_repository.dart';
import 'hive_providers.dart';

/// Task repository provider.
final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return HiveTaskRepository(ref.watch(tasksBoxProvider));
});

/// Schedule repository provider.
final scheduleRepositoryProvider = Provider<IScheduleRepository>((ref) {
  return HiveScheduleRepository(ref.watch(scheduleBoxProvider));
});

/// Expense repository provider.
final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  return HiveExpenseRepository(ref.watch(expensesBoxProvider));
});

/// Appointment repository provider.
final appointmentRepositoryProvider = Provider<IAppointmentRepository>((ref) {
  return HiveAppointmentRepository(ref.watch(appointmentsBoxProvider));
});
