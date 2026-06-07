import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/schedule_entry.dart';
import '../../providers/schedule_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/schedule_form.dart';
import 'widgets/timeline_view.dart';
import 'widgets/week_strip.dart';

/// Schedule timeline screen with week strip navigation.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final date = ref.read(selectedScheduleDateProvider);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: ScheduleForm(
          entry: ScheduleEntry.create(
            title: '',
            date: date,
            startTime: '09:00',
            endTime: '10:00',
          ),
          onSave: (entry) async {
            await ref.read(scheduleNotifierProvider.notifier).add(entry);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedScheduleDateProvider);
    final scheduleAsync = ref.watch(scheduleNotifierProvider);
    final dayEntries = ref.watch(selectedDayScheduleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppStrings.schedule}  ${DateFormat('EEE d MMM').format(selectedDate)}',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: WeekStrip(),
          ),
          Expanded(
            child: scheduleAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(scheduleNotifierProvider),
              ),
              data: (_) => dayEntries.isEmpty
                  ? const EmptyState(message: AppStrings.noSchedule)
                  : TimelineView(entries: dayEntries),
            ),
          ),
        ],
      ),
    );
  }
}
