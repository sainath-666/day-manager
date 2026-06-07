import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'schedule_entry.g.dart';

/// A schedule entry for a single day with optional repeat and notifications.
@HiveType(typeId: 1)
class ScheduleEntry extends HiveObject {
  ScheduleEntry();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? notes;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String startTime;

  @HiveField(5)
  late String endTime;

  @HiveField(6)
  late int repeatMode;

  @HiveField(7)
  late int colorValue;

  @HiveField(8)
  late bool notifyEnabled;

  @HiveField(9)
  late int notifyMinutesBefore;

  Color get color => Color(colorValue);

  /// Creates a new schedule entry with defaults.
  factory ScheduleEntry.create({
    required String title,
    required DateTime date,
    required String startTime,
    required String endTime,
    int repeatMode = 0,
    int colorValue = 0xFF6750A4,
    bool notifyEnabled = true,
    int notifyMinutesBefore = 10,
    String? notes,
  }) {
    return ScheduleEntry()
      ..id = const Uuid().v4()
      ..title = title
      ..notes = notes
      ..date = date
      ..startTime = startTime
      ..endTime = endTime
      ..repeatMode = repeatMode
      ..colorValue = colorValue
      ..notifyEnabled = notifyEnabled
      ..notifyMinutesBefore = notifyMinutesBefore;
  }
}
