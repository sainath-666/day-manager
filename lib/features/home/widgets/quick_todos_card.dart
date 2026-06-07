import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../providers/todo_providers.dart';

class QuickTodosCard extends ConsumerStatefulWidget {
  const QuickTodosCard({super.key});

  @override
  ConsumerState<QuickTodosCard> createState() => _QuickTodosCardState();
}

class _QuickTodosCardState extends ConsumerState<QuickTodosCard> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _filter = 'pending'; // 'all' | 'pending' | 'completed'

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(todosProvider.notifier).addTodo(text);
      _controller.clear();
      // Keep focus on input for fast rapid entry
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allTodos = ref.watch(todosProvider);
    
    // Filtered lists
    final pendingTodos = allTodos.where((t) => t['isCompleted'] == false).toList();
    final completedTodos = allTodos.where((t) => t['isCompleted'] == true).toList();
    
    List<Map<String, dynamic>> displayedTodos;
    if (_filter == 'pending') {
      displayedTodos = pendingTodos;
    } else if (_filter == 'completed') {
      displayedTodos = completedTodos;
    } else {
      displayedTodos = allTodos;
    }

    final totalCount = allTodos.length;
    final completedCount = completedTodos.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      color: colorScheme.surfaceContainerLow.withValues(alpha: 0.6),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.playlist_add_check,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text(
                      'Quick Checklist',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (totalCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$completedCount/$totalCount',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Compact Filters
                Row(
                  children: [
                    _FilterTab(
                      label: 'Active',
                      selected: _filter == 'pending',
                      count: pendingTodos.length,
                      onTap: () => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: 4),
                    _FilterTab(
                      label: 'Done',
                      selected: _filter == 'completed',
                      count: completedTodos.length,
                      onTap: () => setState(() => _filter = 'completed'),
                    ),
                    const SizedBox(width: 4),
                    _FilterTab(
                      label: 'All',
                      selected: _filter == 'all',
                      count: allTodos.length,
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),

            // Inline Input Box
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Add a quick todo...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    icon: Icon(Icons.add_circle, color: colorScheme.primary, size: 24),
                    onPressed: _submit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.md),

            // Checklist Items
            if (displayedTodos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      _filter == 'completed'
                          ? Icons.done_all_outlined
                          : Icons.checklist_outlined,
                      size: 36,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filter == 'completed'
                          ? 'No completed items yet'
                          : _filter == 'pending'
                              ? 'All caught up! Add a new todo'
                              : 'No items in checklist',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedTodos.length,
                itemBuilder: (context, index) {
                  final todo = displayedTodos[index];
                  final String id = todo['id'];
                  final String title = todo['title'];
                  final bool isCompleted = todo['isCompleted'] ?? false;

                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete, color: colorScheme.onErrorContainer, size: 20),
                    ),
                    onDismissed: (_) {
                      ref.read(todosProvider.notifier).deleteTodo(id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Todo deleted: $title'),
                          duration: const Duration(seconds: 2),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              ref.read(todosProvider.notifier).addTodo(title);
                            },
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => ref.read(todosProvider.notifier).toggleTodo(id),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            child: Row(
                              children: [
                                // Checkbox Circle
                                AnimatedContainer(
                                  duration: 200.ms,
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCompleted
                                          ? colorScheme.primary
                                          : colorScheme.outline,
                                      width: 1.5,
                                    ),
                                    color: isCompleted
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    boxShadow: isCompleted
                                        ? [
                                            BoxShadow(
                                              color: colorScheme.primary.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: isCompleted
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Title
                                Expanded(
                                  child: Text(
                                    title,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isCompleted
                                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                                              : colorScheme.onSurface,
                                          fontWeight: isCompleted
                                              ? FontWeight.normal
                                              : FontWeight.w600,
                                        ),
                                  ),
                                ),
                                // Delete
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                                  ),
                                  onPressed: () => ref.read(todosProvider.notifier).deleteTodo(id),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0, duration: 200.ms),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.count,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.8)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
