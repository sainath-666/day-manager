import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/task.dart';
import '../../../providers/task_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import 'priority_chip.dart';

/// Swipeable task list tile.
class TaskTile extends ConsumerWidget {
  const TaskTile({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.check),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return showConfirmDialog(
            context,
            title: AppStrings.delete,
            message: AppStrings.confirmDelete,
          );
        }
        return true;
      },
      onDismissed: (direction) async {
        final notifier = ref.read(tasksNotifierProvider.notifier);
        if (direction == DismissDirection.startToEnd) {
          await notifier.toggleComplete(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(AppStrings.taskCompleted),
                action: SnackBarAction(
                  label: AppStrings.undo,
                  onPressed: () => notifier.toggleComplete(task.id),
                ),
              ),
            );
          }
        } else {
          await notifier.delete(task.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.taskDeleted)),
            );
          }
        }
      },
      child: ListTile(
        leading: PriorityIndicator(priority: task.priority),
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: task.dueTime != null ? Text(task.dueTime!) : null,
        trailing: task.notificationScheduled
            ? const Icon(Icons.notifications_active, size: 18)
            : null,
        onTap: () => context.push('/tasks/${task.id}'),
      ),
    );
  }
}
