import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../constants/feature_flags.dart';
import '../../data/models/expense.dart';
import '../../data/models/schedule_entry.dart';
import '../../data/models/task.dart';

/// Loads static seed data on first launch.
class SeedData {
  SeedData._();

  static Future<void> load() async {
    final settingsBox = await Hive.openBox('settings');
    if (settingsBox.get(kSeedDataLoadedKey, defaultValue: false) == true) {
      return;
    }

    final jsonStr = await rootBundle.loadString('assets/seed_data.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    final taskBox = Hive.box<Task>('tasks');
    final scheduleBox = Hive.box<ScheduleEntry>('schedule');
    final expenseBox = Hive.box<Expense>('expenses');

    for (final item in data['tasks'] as List) {
      final map = Map<String, dynamic>.from(item as Map);
      final task = Task()
        ..id = map['id'] as String
        ..title = map['title'] as String
        ..description = map['description'] as String?
        ..createdAt = DateTime.now()
        ..dueDate = _resolveDate(map['dueDate'] as String?)
        ..dueTime = map['dueTime'] as String?
        ..priority = map['priority'] as int
        ..isCompleted = map['isCompleted'] as bool? ?? false
        ..tags = List<String>.from(map['tags'] as List? ?? [])
        ..notificationScheduled = false;
      await taskBox.put(task.id, task);
    }

    final today = DateTime.now();
    for (final item in data['schedule_entries'] as List) {
      final map = Map<String, dynamic>.from(item as Map);
      final entry = ScheduleEntry()
        ..id = map['id'] as String
        ..title = map['title'] as String
        ..date = DateTime(today.year, today.month, today.day)
        ..startTime = map['startTime'] as String
        ..endTime = map['endTime'] as String
        ..repeatMode = map['repeatMode'] as int
        ..colorValue = map['colorValue'] as int
        ..notifyEnabled = map['notifyEnabled'] as bool? ?? false
        ..notifyMinutesBefore = map['notifyMinutesBefore'] as int? ?? 10;
      await scheduleBox.put(entry.id, entry);
    }

    for (final item in data['expenses'] as List) {
      final map = Map<String, dynamic>.from(item as Map);
      final daysAgo = map['daysAgo'] as int? ?? 0;
      final expense = Expense()
        ..id = map['id'] as String
        ..amount = (map['amount'] as num).toDouble()
        ..category = map['category'] as int
        ..description = map['description'] as String
        ..date = DateTime.now().subtract(Duration(days: daysAgo))
        ..paymentMethod = map['paymentMethod'] as int
        ..createdAt = DateTime.now().subtract(Duration(days: daysAgo));
      await expenseBox.put(expense.id, expense);
    }

    await settingsBox.put(kSeedDataLoadedKey, true);
  }

  static DateTime? _resolveDate(String? token) {
    if (token == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (token) {
      case 'TODAY':
        return today;
      case 'TOMORROW':
        return today.add(const Duration(days: 1));
      case 'IN_3_DAYS':
        return today.add(const Duration(days: 3));
      default:
        return DateTime.tryParse(token);
    }
  }
}
