import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/extensions/date_time_ext.dart';
import '../data/models/schedule_entry.dart';
import 'repository_providers.dart';

/// Selected date for schedule view.
final selectedScheduleDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

/// All schedule entries notifier.
class ScheduleNotifier extends AsyncNotifier<List<ScheduleEntry>> {
  @override
  Future<List<ScheduleEntry>> build() async {
    final repo = ref.watch(scheduleRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(ScheduleEntry entry) async {
    await ref.read(scheduleRepositoryProvider).add(entry);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(ScheduleEntry entry) async {
    await ref.read(scheduleRepositoryProvider).update(entry);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(scheduleRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final scheduleNotifierProvider =
    AsyncNotifierProvider<ScheduleNotifier, List<ScheduleEntry>>(
  ScheduleNotifier.new,
);

/// Schedule entries for the selected date.
final selectedDayScheduleProvider = Provider<List<ScheduleEntry>>((ref) {
  final date = ref.watch(selectedScheduleDateProvider);
  final allAsync = ref.watch(scheduleNotifierProvider);
  return allAsync.when(
    data: (entries) {
      final dayEntries =
          entries.where((e) => e.date.isSameDay(date)).toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
      return dayEntries;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
