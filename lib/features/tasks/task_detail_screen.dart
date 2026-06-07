import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/enums/priority.dart';
import '../../core/extensions/date_time_ext.dart';
import '../../providers/repository_providers.dart';
import '../../providers/task_providers.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/task_form.dart';
import 'widgets/priority_chip.dart';

/// Task detail and edit screen.
class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taskId == 'new') {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.addTask)),
        body: TaskForm(
          onSave: (task) async {
            await ref.read(tasksNotifierProvider.notifier).add(task);
            if (context.mounted) context.pop();
          },
        ),
      );
    }

    final taskAsync = ref.watch(
      FutureProvider((ref) => ref.watch(taskRepositoryProvider).getById(taskId)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tasks),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(tasksNotifierProvider.notifier).delete(taskId);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(height: 300),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (task) {
          if (task == null) {
            return const Center(child: Text('Task not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (task.description != null) Text(task.description!),
              const SizedBox(height: 8),
              Row(
                children: [
                  Hero(
                    tag: 'task-priority-${task.id}',
                    child: PriorityIndicator(priority: task.priority),
                  ),
                  const SizedBox(width: 8),
                  Text('Priority: ${Priority.fromInt(task.priority).label}'),
                ],
              ),
              if (task.dueDate != null)
                Text('Due: ${task.dueDate!.formatDisplay()} ${task.dueTime ?? ''}'),
              const Divider(),
              TaskForm(
                task: task,
                onSave: (updated) async {
                  await ref.read(tasksNotifierProvider.notifier).updateTask(updated);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
