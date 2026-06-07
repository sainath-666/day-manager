import 'dart:io';
import 'package:dailyflow/app.dart';
import 'package:dailyflow/data/models/bill_note.dart';
import 'package:dailyflow/data/models/expense.dart';
import 'package:dailyflow/data/models/schedule_entry.dart';
import 'package:dailyflow/data/models/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Initialize in a temporary test directory
    final tempDir = Directory.systemTemp.createTempSync('hive_test_widget');
    Hive.init(tempDir.path);
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(TaskAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ScheduleEntryAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ExpenseAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BillNoteAdapter());
    
    // Open boxes
    await Future.wait([
      Hive.openBox<Task>('tasks'),
      Hive.openBox<ScheduleEntry>('schedule'),
      Hive.openBox<Expense>('expenses'),
      Hive.openBox<BillNote>('bill_notes'),
      Hive.openBox('settings'),
      Hive.openBox('todos'),
    ]);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App smoke test', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DailyFlowApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
