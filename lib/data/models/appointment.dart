import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'appointment.g.dart';

/// A scheduled appointment with provider, location, and status tracking.
@HiveType(typeId: 4)
class Appointment extends HiveObject {
  Appointment();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? providerName;

  @HiveField(3)
  String? location;

  @HiveField(4)
  late int appointmentType;

  @HiveField(5)
  late DateTime date;

  @HiveField(6)
  late String time;

  @HiveField(7)
  late int durationMinutes;

  @HiveField(8)
  late int status;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  late bool notifyEnabled;

  @HiveField(11)
  late int notifyMinutesBefore;

  @HiveField(12)
  late int colorValue;

  Color get color => Color(colorValue);

  /// Creates a new appointment with defaults.
  factory Appointment.create({
    required String title,
    required DateTime date,
    required String time,
    String? providerName,
    String? location,
    int appointmentType = 0,
    int durationMinutes = 30,
    int status = 0,
    String? notes,
    bool notifyEnabled = true,
    int notifyMinutesBefore = 30,
    int colorValue = 0xFF3B82F6,
  }) {
    return Appointment()
      ..id = const Uuid().v4()
      ..title = title
      ..providerName = providerName
      ..location = location
      ..appointmentType = appointmentType
      ..date = date
      ..time = time
      ..durationMinutes = durationMinutes
      ..status = status
      ..notes = notes
      ..notifyEnabled = notifyEnabled
      ..notifyMinutesBefore = notifyMinutesBefore
      ..colorValue = colorValue;
  }
}
