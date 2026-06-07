import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/expense_providers.dart';
import '../../providers/task_providers.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/quick_add_fab.dart';
import 'widgets/summary_card.dart';
import 'widgets/upcoming_reminders_section.dart';

/// Home dashboard with progress, upcoming items, and spend summary.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final upcoming = ref.watch(upcomingRemindersProvider);
    final currentSpend = ref.watch(currentMonthSpendProvider);
    final lastSpend = ref.watch(lastMonthSpendProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('$_greeting, Rahul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/analytics'),
            tooltip: AppStrings.analytics,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: AppStrings.settings,
          ),
        ],
      ),
      floatingActionButton: const QuickAddFab(),
      body: tasksAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSizes.md),
          child: LoadingSkeleton(height: 200),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (_) => RefreshIndicator(
          onRefresh: () => ref.refresh(tasksNotifierProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              SummaryCard(
                completionRate: completionRate,
                completedCount: todayTasks.where((t) => t.isCompleted).length,
                totalCount: todayTasks.length,
              ),
              const SizedBox(height: AppSizes.md),
              UpcomingRemindersSection(items: upcoming),
              const SizedBox(height: AppSizes.md),
              SpendSummaryCard(
                currentSpend: currentSpend,
                lastSpend: lastSpend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
