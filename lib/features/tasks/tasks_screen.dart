import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/task_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/task_form.dart';
import 'widgets/task_tile.dart';

/// Tasks list with Today / Upcoming / All tabs.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: TaskForm(
          onSave: (task) async {
            await ref.read(tasksNotifierProvider.notifier).add(task);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final upcomingTasks = ref.watch(upcomingTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tasks),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: AppStrings.today),
            Tab(text: AppStrings.upcoming),
            Tab(text: AppStrings.all),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => ListView.builder(
          itemCount: 5,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.all(8),
            child: LoadingSkeleton(),
          ),
        ),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(tasksNotifierProvider),
        ),
        data: (allTasks) => TabBarView(
          controller: _tabController,
          children: [
            _TaskList(
              tasks: todayTasks,
              emptyMessage: AppStrings.noTasksToday,
            ),
            _TaskList(
              tasks: upcomingTasks,
              emptyMessage: AppStrings.noTasks,
            ),
            _TaskList(
              tasks: allTasks,
              emptyMessage: AppStrings.noTasks,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.emptyMessage,
  });

  final List tasks;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(message: emptyMessage);
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (_, i) => TaskTile(task: tasks[i]),
    );
  }
}
