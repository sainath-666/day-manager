import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

/// A task with optional due date/time and local notification support.
@HiveType(typeId: 0)
class Task extends HiveObject {
  Task();

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  String? dueTime;

  @HiveField(6)
  late int priority;

  @HiveField(7)
  late bool isCompleted;

  @HiveField(8)
  DateTime? completedAt;

  @HiveField(9)
  late List<String> tags;

  @HiveField(10, defaultValue: false)
  bool notificationScheduled = false;

  /// Creates a new task with auto-generated id and timestamp.
  factory Task.create({
    required String title,
    String? description,
    DateTime? dueDate,
    String? dueTime,
    int priority = 0,
    List<String> tags = const [],
  }) {
    return Task()
      ..id = const Uuid().v4()
      ..title = title
      ..description = description
      ..createdAt = DateTime.now()
      ..dueDate = dueDate
      ..dueTime = dueTime
      ..priority = priority
      ..isCompleted = false
      ..tags = List<String>.from(tags)
      ..notificationScheduled = false;
  }
}
