import 'package:dailyflow/core/extensions/date_time_ext.dart';
import 'package:dailyflow/data/models/task.dart';
import 'package:dailyflow/data/repositories/i_task_repository.dart';
import 'package:dailyflow/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dailyflow/providers/repository_providers.dart';

class FakeTaskRepository implements ITaskRepository {
  final List<Task> tasks = [];

  @override
  Future<void> add(Task task) async => tasks.add(task);

  @override
  Future<void> delete(String id) async => tasks.removeWhere((t) => t.id == id);

  @override
  Future<List<Task>> getAll() async => tasks;

  @override
  Future<Task?> getById(String id) async =>
      tasks.cast<Task?>().firstWhere((t) => t?.id == id, orElse: () => null);

  @override
  Future<List<Task>> getByDate(DateTime date) async =>
      tasks.where((t) => t.dueDate?.isSameDay(date) == true).toList();

  @override
  Future<void> toggleComplete(String id) async {}

  @override
  Future<void> update(Task task) async {}

  @override
  Stream<List<Task>> watchAll() => Stream.value(tasks);
}

void main() {
  test('todayTasksProvider returns only today tasks sorted by time', () async {
    final fake = FakeTaskRepository();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    fake.tasks.addAll([
      Task.create(title: 'Late', dueDate: todayDate, dueTime: '18:00'),
      Task.create(title: 'Early', dueDate: todayDate, dueTime: '07:00'),
      Task.create(
        title: 'Tomorrow',
        dueDate: todayDate.add(const Duration(days: 1)),
        dueTime: '09:00',
      ),
    ]);

    final container = ProviderContainer(
      overrides: [taskRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    await container.read(tasksNotifierProvider.future);
    final todayTasks = container.read(todayTasksProvider);

    expect(todayTasks.length, 2);
    expect(todayTasks.first.title, 'Early');
    expect(todayTasks.last.title, 'Late');
  });
}
