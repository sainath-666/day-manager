import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/task_providers.dart';
import 'widgets/task_form.dart';

/// Dedicated create-task route for dashboard and quick actions.
class TaskCreateScreen extends ConsumerWidget {
  const TaskCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addTask)),
      body: SafeArea(
        child: TaskForm(
          onSave: (task) async {
            await ref.read(tasksNotifierProvider.notifier).add(task);
            if (context.mounted) {
              context.go('/tasks');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task added')),
              );
            }
          },
        ),
      ),
    );
  }
}
