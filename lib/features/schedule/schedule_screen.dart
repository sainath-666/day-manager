import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/schedule_entry.dart';
import '../../features/appointments/widgets/appointment_form.dart';
import '../../features/appointments/widgets/appointments_list_view.dart';
import '../../providers/appointment_providers.dart';
import '../../providers/schedule_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/schedule_form.dart';
import 'widgets/timeline_view.dart';
import 'widgets/week_strip.dart';

/// Schedule screen with timeline and appointments tabs.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  void _showAddScheduleSheet(BuildContext context, WidgetRef ref) {
    final date = ref.read(selectedScheduleDateProvider);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: ScheduleForm(
          initialDate: date,
          onSave: (entry) async {
            await ref.read(scheduleNotifierProvider.notifier).add(entry);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showAddAppointmentSheet(BuildContext context, WidgetRef ref) {
    final date = ref.read(selectedScheduleDateProvider);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: AppointmentForm(
          initialDate: date,
          onSave: (appointment) async {
            await ref.read(appointmentsNotifierProvider.notifier).add(appointment);
            if (ctx.mounted) Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedScheduleDateProvider);
    final tabIndex = ref.watch(scheduleTabIndexProvider);
    final scheduleAsync = ref.watch(scheduleNotifierProvider);
    final appointmentsAsync = ref.watch(appointmentsNotifierProvider);
    final dayEntries = ref.watch(selectedDayScheduleProvider);
    final dayAppointments = ref.watch(selectedDayAppointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${AppStrings.schedule}  ${DateFormat('EEE d MMM').format(selectedDate)}',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => tabIndex == 0
            ? _showAddScheduleSheet(context, ref)
            : _showAddAppointmentSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: WeekStrip(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text(AppStrings.timeline),
                  icon: Icon(Icons.view_timeline_outlined),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text(AppStrings.appointments),
                  icon: Icon(Icons.event_note_outlined),
                ),
              ],
              selected: {tabIndex},
              onSelectionChanged: (s) =>
                  ref.read(scheduleTabIndexProvider.notifier).state = s.first,
            ),
          ),
          if (tabIndex == 0) ...[
            _ScheduleDaySummary(
              selectedDate: selectedDate,
              entries: dayEntries,
            ),
            Expanded(
              child: scheduleAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(scheduleNotifierProvider),
                ),
                data: (_) => dayEntries.isEmpty
                    ? EmptyState(
                        message: AppStrings.noSchedule,
                        icon: Icons.event_available_outlined,
                        actionLabel: AppStrings.addSchedule,
                        onAction: () => _showAddScheduleSheet(context, ref),
                      )
                    : TimelineView(entries: dayEntries),
              ),
            ),
          ] else ...[
            AppointmentsDaySummary(
              selectedDate: selectedDate,
              appointments: dayAppointments,
            ),
            Expanded(
              child: appointmentsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(appointmentsNotifierProvider),
                ),
                data: (_) => dayAppointments.isEmpty
                    ? EmptyState(
                        message: AppStrings.noAppointments,
                        icon: Icons.event_busy_outlined,
                        actionLabel: AppStrings.addAppointment,
                        onAction: () => _showAddAppointmentSheet(context, ref),
                      )
                    : AppointmentsListView(appointments: dayAppointments),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleDaySummary extends StatelessWidget {
  const _ScheduleDaySummary({
    required this.selectedDate,
    required this.entries,
  });

  final DateTime selectedDate;
  final List<ScheduleEntry> entries;

  int _minutesFor(ScheduleEntry entry) {
    final start = entry.startTime.split(':');
    final end = entry.endTime.split(':');
    final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
    final endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
    return (endMin - startMin).clamp(0, 24 * 60);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalMinutes = entries.fold<int>(0, (sum, e) => sum + _minutesFor(e));
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeLabel = totalMinutes == 0
        ? 'Open day'
        : hours == 0
            ? '$minutes min planned'
            : minutes == 0
                ? '$hours hr planned'
                : '$hours hr $minutes min planned';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(selectedDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entries.length} meetings/events - $timeLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
