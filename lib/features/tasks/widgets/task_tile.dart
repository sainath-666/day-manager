import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/task.dart';
import '../../../providers/task_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import 'priority_chip.dart';

/// Swipeable task list tile, supporting selection mode.
class TaskTile extends ConsumerWidget {
  const TaskTile({
    super.key,
    required this.task,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
  });

  final Task task;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build the main list tile widget
    final listTile = ListTile(
      leading: isSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap?.call(),
              activeColor: colorScheme.primary,
            )
          : PriorityIndicator(priority: task.priority),
      title: Text(
        task.title,
        style: task.isCompleted
            ? TextStyle(
                decoration: TextDecoration.lineThrough,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              )
            : null,
      ),
      subtitle: task.dueTime != null ? Text(task.dueTime!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Wrap(
                spacing: 4,
                children: task.tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                )).toList(),
              ),
            ),
          if (task.notificationScheduled)
            Icon(Icons.notifications_active, size: 18, color: colorScheme.primary),
        ],
      ),
      onTap: isSelectionMode ? onTap : () => context.push('/tasks/${task.id}'),
      onLongPress: onLongPress,
    );

    // Disable dismiss actions when in selection mode
    if (isSelectionMode) {
      return Container(
        color: isSelected ? colorScheme.primaryContainer.withValues(alpha: 0.15) : null,
        child: listTile,
      );
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(Icons.check, color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onErrorContainer),
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
      child: listTile,
    );
  }
}
