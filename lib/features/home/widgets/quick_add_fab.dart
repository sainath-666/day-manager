import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';

/// Expandable FAB for quick-add actions.
class QuickAddFab extends StatefulWidget {
  const QuickAddFab({super.key});

  @override
  State<QuickAddFab> createState() => _QuickAddFabState();
}

class _QuickAddFabState extends State<QuickAddFab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_expanded) ...[
          FloatingActionButton.small(
            heroTag: 'add_task',
            onPressed: () => context.push('/tasks/new'),
            child: const Icon(Icons.task_alt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'add_expense',
            onPressed: () => context.push('/scan'),
            child: const Icon(Icons.receipt_long),
          ),
          const SizedBox(height: 8),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: _toggle,
          tooltip: AppStrings.addTask,
          child: Icon(_expanded ? Icons.close : Icons.add),
        ),
      ],
    );
  }
}
