import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/analytics_providers.dart';
import '../../providers/expense_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/task_providers.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/quick_add_fab.dart';
import 'widgets/summary_card.dart';
import 'widgets/upcoming_reminders_section.dart';
import 'widgets/quick_todos_card.dart';

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
    final profile = ref.watch(userProfileProvider);

    final dateStr = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('DailyFlow', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0)),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            children: [
              // In-body Rich Greeting Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      Theme.of(context).colorScheme.secondary.withValues(alpha: 0.03),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()}, ${profile.name}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).colorScheme.onSurface,
                                  letterSpacing: 0,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateStr,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSizes.md),

              // Quick Actions Row
              const QuickActionsRow()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 50.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSizes.md),

              // Progress Card
              SummaryCard(
                completionRate: completionRate,
                completedCount: todayTasks.where((t) => t.isCompleted).length,
                totalCount: todayTasks.length,
              ),
              const SizedBox(height: AppSizes.md),

              // Quick Checklist
              const QuickTodosCard()
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 100.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSizes.md),

              // Upcoming Reminders
              UpcomingRemindersSection(items: upcoming)
                  .animate()
                  .fadeIn(duration: 450.ms, delay: 150.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
              const SizedBox(height: AppSizes.md),

              // Spend Summary Card
              SpendSummaryCard(
                currentSpend: currentSpend,
                lastSpend: lastSpend,
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionBtn(
          icon: Icons.add_task_outlined,
          label: 'New Task',
          color: const Color(0xFF6366F1), // Premium Indigo
          onTap: () => context.push('/tasks/new'),
        ),
        _ActionBtn(
          icon: Icons.document_scanner_outlined,
          label: 'Scan Bill',
          color: const Color(0xFF14B8A6), // Premium Mint Teal
          onTap: () => context.push('/scan'),
        ),
        _ActionBtn(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          color: const Color(0xFF8B5CF6), // Premium Violet
          onTap: () => context.push('/analytics'),
        ),
        _ActionBtn(
          icon: Icons.settings_outlined,
          label: 'Settings',
          color: const Color(0xFFF59E0B), // Premium Amber Orange
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Expanded(
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow.withValues(alpha: isDark ? 0.7 : 0.9),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.75),
            width: 1.0,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.9),
                        color.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
