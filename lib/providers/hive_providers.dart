import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/models/appointment.dart';
import '../data/models/bill_note.dart';
import '../data/models/expense.dart';
import '../data/models/schedule_entry.dart';
import '../data/models/task.dart';

/// Provider for the tasks Hive box.
final tasksBoxProvider = Provider<Box<Task>>((ref) => Hive.box<Task>('tasks'));

/// Provider for the schedule Hive box.
final scheduleBoxProvider =
    Provider<Box<ScheduleEntry>>((ref) => Hive.box<ScheduleEntry>('schedule'));

/// Provider for the expenses Hive box.
final expensesBoxProvider =
    Provider<Box<Expense>>((ref) => Hive.box<Expense>('expenses'));

/// Provider for the bill notes Hive box.
final billNotesBoxProvider =
    Provider<Box<BillNote>>((ref) => Hive.box<BillNote>('bill_notes'));

/// Provider for the appointments Hive box.
final appointmentsBoxProvider = Provider<Box<Appointment>>(
  (ref) => Hive.box<Appointment>('appointments'),
);
