import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'core/constants/feature_flags.dart';
import 'core/utils/notification_service.dart';
import 'core/utils/seed_data.dart';
import 'data/models/bill_note.dart';
import 'data/models/expense.dart';
import 'data/models/schedule_entry.dart';
import 'data/models/task.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(ScheduleEntryAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BillNoteAdapter());

  await Future.wait([
    Hive.openBox<Task>('tasks'),
    Hive.openBox<ScheduleEntry>('schedule'),
    Hive.openBox<Expense>('expenses'),
    Hive.openBox<BillNote>('bill_notes'),
  ]);

  await NotificationService.init();
  tz.initializeTimeZones();
  final timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  if (kLoadSeedData) {
    await SeedData.load();
  }

  runApp(const ProviderScope(child: DailyFlowApp()));
}
