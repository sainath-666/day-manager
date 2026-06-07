import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions/date_time_ext.dart';
import '../data/models/task.dart';
import 'repository_providers.dart';

/// All tasks notifier.
class TasksNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.add(task);
    ref.invalidateSelf();
  }

  Future<void> updateTask(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.update(task);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(String id) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleComplete(id);
    ref.invalidateSelf();
  }
}

final tasksNotifierProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

/// Tasks due today, sorted by time.
final todayTasksProvider = Provider<List<Task>>((ref) {
  final allTasksAsync = ref.watch(tasksNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final today = tasks.where((t) => t.dueDate?.isToday == true).toList()
        ..sort((a, b) => (a.dueTime ?? '99:99').compareTo(b.dueTime ?? '99:99'));
      return today;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Upcoming tasks (future due dates, not completed).
final upcomingTasksProvider = Provider<List<Task>>((ref) {
  final allTasksAsync = ref.watch(tasksNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return tasks
          .where((t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.isAfter(today))
          .toList()
        ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Today's task completion rate (0.0–1.0).
final todayCompletionRateProvider = Provider<double>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  if (tasks.isEmpty) return 0.0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
});
