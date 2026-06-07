import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

import '../../core/extensions/date_time_ext.dart';
import '../../core/utils/notification_service.dart';
import '../models/task.dart';
import 'i_task_repository.dart';

/// Hive-backed task repository with notification scheduling.
class HiveTaskRepository implements ITaskRepository {
  HiveTaskRepository(this._box);

  final Box<Task> _box;

  @override
  Future<List<Task>> getAll() async {
    final tasks = _box.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return tasks;
  }

  @override
  Future<List<Task>> getByDate(DateTime date) async =>
      _box.values.where((t) => t.dueDate?.isSameDay(date) == true).toList();

  @override
  Future<Task?> getById(String id) async => _box.get(id);

  @override
  Future<void> add(Task task) async {
    await _box.put(task.id, task);
    if (task.dueDate != null && task.dueTime != null && !task.isCompleted) {
      await _scheduleNotification(task);
    }
  }

  @override
  Future<void> update(Task task) async {
    await _box.put(task.id, task);
    await NotificationService.cancel(task.id.hashCode);
    if (!task.isCompleted && task.dueDate != null && task.dueTime != null) {
      await _scheduleNotification(task);
    }
  }

  @override
  Future<void> delete(String id) async {
    await NotificationService.cancel(id.hashCode);
    await _box.delete(id);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final task = _box.get(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await task.save();
    HapticFeedback.lightImpact();
    if (task.isCompleted) {
      await NotificationService.cancel(id.hashCode);
      task.notificationScheduled = false;
      await task.save();
    } else if (task.dueDate != null && task.dueTime != null) {
      await _scheduleNotification(task);
    }
  }

  @override
  Stream<List<Task>> watchAll() =>
      _box.watch().map((_) => _box.values.toList());

  Future<void> _scheduleNotification(Task task) async {
    final timeParts = task.dueTime!.split(':');
    final scheduledAt = task.dueDate!.copyWithTime(
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    if (scheduledAt.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskReminder(
        id: task.id.hashCode,
        title: '⏰ ${task.title}',
        body: task.description ?? 'Task is due now',
        scheduledAt: scheduledAt,
        payload: task.id,
      );
      task.notificationScheduled = true;
      await task.save();
    }
  }
}
