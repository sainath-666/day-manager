import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailyflow/core/constants/app_strings.dart';
import 'package:dailyflow/core/utils/app_animations.dart';
import 'package:dailyflow/core/enums/priority.dart';
import 'package:dailyflow/data/models/task.dart';
import 'package:dailyflow/providers/task_providers.dart';
import 'package:dailyflow/shared/widgets/empty_state.dart';
import 'package:dailyflow/shared/widgets/error_view.dart';
import 'package:dailyflow/shared/widgets/loading_skeleton.dart';
import 'package:dailyflow/shared/widgets/confirm_dialog.dart';
import 'widgets/task_form.dart';
import 'widgets/task_tile.dart';

/// Tasks list with Today / Upcoming / All tabs, search, filtering, and bulk actions.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Search & Filter State
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int? _filterPriority;
  String? _filterTag;
  bool? _filterCompleted; // null = all, true = completed, false = active

  // Bulk Selection State
  final Set<String> _selectedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    AppAnimations.showBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TaskForm(
          onSave: (task) async {
            await ref.read(tasksNotifierProvider.notifier).add(task);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showFilterSheet(List<Task> allTasks) {
    final uniqueTags = allTasks.expand((t) => t.tags).toSet().toList();

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterPriority = null;
                              _filterTag = null;
                              _filterCompleted = null;
                            });
                            setSheetState(() {});
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Priority Filter
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: Priority.values.map((p) {
                        final selected = _filterPriority == p.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(p.label),
                            selected: selected,
                            selectedColor: p.color.withValues(alpha: 0.25),
                            checkmarkColor: p.color,
                            onSelected: (val) {
                              setState(() {
                                _filterPriority = val ? p.value : null;
                              });
                              setSheetState(() {});
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Tags Filter
                    if (uniqueTags.isNotEmpty) ...[
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: uniqueTags.map((tag) {
                            final selected = _filterTag == tag;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(tag),
                                selected: selected,
                                onSelected: (val) {
                                  setState(() {
                                    _filterTag = val ? tag : null;
                                  });
                                  setSheetState(() {});
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Status Filter
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('Active'),
                          selected: _filterCompleted == false,
                          onSelected: (val) {
                            setState(() {
                              _filterCompleted = val ? false : null;
                            });
                            setSheetState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Completed'),
                          selected: _filterCompleted == true,
                          onSelected: (val) {
                            setState(() {
                              _filterCompleted = val ? true : null;
                            });
                            setSheetState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Task> _applySearchAndFilter(List<Task> tasks) {
    var list = List<Task>.from(tasks);

    // Apply search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((t) => t.title.toLowerCase().contains(query) || (t.description?.toLowerCase().contains(query) ?? false)).toList();
    }

    // Apply priority filter
    if (_filterPriority != null) {
      list = list.where((t) => t.priority == _filterPriority).toList();
    }

    // Apply tag filter
    if (_filterTag != null) {
      list = list.where((t) => t.tags.contains(_filterTag)).toList();
    }

    // Apply completion status filter
    if (_filterCompleted != null) {
      list = list.where((t) => t.isCompleted == _filterCompleted).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);

    final isSelectionMode = _selectedTaskIds.isNotEmpty;

    return Scaffold(
      appBar: isSelectionMode
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedTaskIds.clear()),
              ),
              title: Text('${_selectedTaskIds.length} Selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  tooltip: 'Bulk Toggle Complete',
                  onPressed: () async {
                    final notifier = ref.read(tasksNotifierProvider.notifier);
                    for (final id in _selectedTaskIds) {
                      await notifier.toggleComplete(id);
                    }
                    setState(() => _selectedTaskIds.clear());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bulk status updated')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Bulk Delete',
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Delete Selected',
                      message: 'Are you sure you want to delete ${_selectedTaskIds.length} tasks?',
                    );
                    if (confirm == true) {
                      final notifier = ref.read(tasksNotifierProvider.notifier);
                      for (final id in _selectedTaskIds) {
                        await notifier.delete(id);
                      }
                      setState(() => _selectedTaskIds.clear());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Selected tasks deleted')),
                        );
                      }
                    }
                  },
                ),
              ],
            )
          : AppBar(
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search tasks...',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  : const Text(AppStrings.tasks),
              leading: _isSearching
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              actions: [
                if (_isSearching)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                tasksAsync.maybeWhen(
                  data: (allTasks) => IconButton(
                    icon: Icon(
                      _filterPriority != null || _filterTag != null || _filterCompleted != null
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                      color: _filterPriority != null || _filterTag != null || _filterCompleted != null
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    onPressed: () => _showFilterSheet(allTasks),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: AppStrings.today),
                  Tab(text: AppStrings.upcoming),
                  Tab(text: AppStrings.all),
                ],
              ),
            ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: _showAddSheet,
              child: const Icon(Icons.add),
            ),
      body: tasksAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.all(8),
            child: LoadingSkeleton(index: i),
          ),
        ),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(tasksNotifierProvider),
        ),
        data: (allTasks) {
          final filteredToday = _applySearchAndFilter(todayTasks);
          final filteredUpcoming = _applySearchAndFilter(upcomingTasks);
          final filteredAll = _applySearchAndFilter(allTasks);

          return TabBarView(
            controller: _tabController,
            children: [
              _TaskList(
                tasks: filteredToday,
                emptyMessage: AppStrings.noTasksToday,
                selectedTaskIds: _selectedTaskIds,
                onSelectionChanged: () => setState(() {}),
              ),
              _TaskList(
                tasks: filteredUpcoming,
                emptyMessage: AppStrings.noTasks,
                selectedTaskIds: _selectedTaskIds,
                onSelectionChanged: () => setState(() {}),
              ),
              _TaskList(
                tasks: filteredAll,
                emptyMessage: AppStrings.noTasks,
                selectedTaskIds: _selectedTaskIds,
                onSelectionChanged: () => setState(() {}),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskList extends StatefulWidget {
  const _TaskList({
    required this.tasks,
    required this.emptyMessage,
    required this.selectedTaskIds,
    required this.onSelectionChanged,
  });

  final List<Task> tasks;
  final String emptyMessage;
  final Set<String> selectedTaskIds;
  final VoidCallback onSelectionChanged;

  @override
  State<_TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<_TaskList> {
  bool _isCompletedExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return EmptyState(message: widget.emptyMessage);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isSelectionMode = widget.selectedTaskIds.isNotEmpty;

    final pending = widget.tasks.where((t) => !t.isCompleted).toList();
    final completed = widget.tasks.where((t) => t.isCompleted).toList();

    // Flatten lists to build a single ListView with headers
    final listItems = <Widget>[];

    if (pending.isNotEmpty) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'PENDING',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${pending.length}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      var tileIndex = 0;
      listItems.addAll(
        pending.map((task) => _buildTaskTile(task, isSelectionMode, tileIndex++)),
      );
    }

    if (completed.isNotEmpty) {
      listItems.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Card(
            elevation: 0,
            color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCompletedExpanded = !_isCompletedExpanded;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          'COMPLETED',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${completed.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      _isCompletedExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      listItems.add(
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: completed
                .asMap()
                .entries
                .map((e) => _buildTaskTile(e.value, isSelectionMode, e.key + pending.length))
                .toList(),
          ),
          crossFadeState: _isCompletedExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: AppAnimations.normal,
          sizeCurve: AppAnimations.enterCurve,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 132),
      itemCount: listItems.length,
      itemBuilder: (_, index) => listItems[index],
    );
  }

  Widget _buildTaskTile(Task task, bool isSelectionMode, int index) {
    final isSelected = widget.selectedTaskIds.contains(task.id);
    return TaskTile(
      task: task,
      index: index,
      isSelected: isSelected,
      isSelectionMode: isSelectionMode,
      onTap: () {
        if (isSelectionMode) {
          if (isSelected) {
            widget.selectedTaskIds.remove(task.id);
          } else {
            widget.selectedTaskIds.add(task.id);
          }
          widget.onSelectionChanged();
        }
      },
      onLongPress: () {
        if (!isSelectionMode) {
          widget.selectedTaskIds.add(task.id);
          widget.onSelectionChanged();
        }
      },
    );
  }
}
