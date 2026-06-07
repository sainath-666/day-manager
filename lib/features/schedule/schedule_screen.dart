import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/enums/repeat_mode.dart' as app_repeat;
import '../../data/models/schedule_entry.dart';
import '../../providers/schedule_providers.dart';
import '../../shared/widgets/date_time_picker_field.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/timeline_view.dart';
import 'widgets/week_strip.dart';

/// Schedule timeline screen with week strip navigation.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    var title = '';
    var startTime = '09:00';
    var endTime = '10:00';
    var repeatMode = app_repeat.RepeatMode.none;
    var notifyEnabled = true;
    var notifyBefore = 10;
    final date = ref.read(selectedScheduleDateProvider);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: AppStrings.title),
                onChanged: (v) => title = v,
              ),
              TimePickerField(
                label: AppStrings.startTime,
                value: startTime,
                onChanged: (v) => setState(() => startTime = v ?? startTime),
              ),
              TimePickerField(
                label: AppStrings.endTime,
                value: endTime,
                onChanged: (v) => setState(() => endTime = v ?? endTime),
              ),
              DropdownButtonFormField<app_repeat.RepeatMode>(
                initialValue: repeatMode,
                decoration: const InputDecoration(labelText: AppStrings.repeat),
                items: app_repeat.RepeatMode.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                    .toList(),
                onChanged: (v) => setState(() => repeatMode = v ?? repeatMode),
              ),
              SwitchListTile(
                title: const Text(AppStrings.notifications),
                value: notifyEnabled,
                onChanged: (v) => setState(() => notifyEnabled = v),
              ),
              FilledButton(
                onPressed: () async {
                  if (title.trim().isEmpty) return;
                  final entry = ScheduleEntry.create(
                    title: title.trim(),
                    date: date,
                    startTime: startTime,
                    endTime: endTime,
                    repeatMode: repeatMode.value,
                    notifyEnabled: notifyEnabled,
                    notifyMinutesBefore: notifyBefore,
                  );
                  await ref.read(scheduleNotifierProvider.notifier).add(entry);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text(AppStrings.save),
              ),
            ],
          ),
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
