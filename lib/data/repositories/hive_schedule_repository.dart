import 'package:hive/hive.dart';

import '../../core/extensions/date_time_ext.dart';
import '../../core/utils/notification_service.dart';
import '../models/schedule_entry.dart';
import 'i_schedule_repository.dart';

/// Hive-backed schedule repository with notification scheduling.
class HiveScheduleRepository implements IScheduleRepository {
  HiveScheduleRepository(this._box);

  final Box<ScheduleEntry> _box;

  @override
  Future<List<ScheduleEntry>> getAll() async => _box.values.toList();

  @override
  Future<List<ScheduleEntry>> getByDate(DateTime date) async =>
      _box.values.where((e) => e.date.isSameDay(date)).toList();

  @override
  Future<ScheduleEntry?> getById(String id) async => _box.get(id);

  @override
  Future<void> add(ScheduleEntry entry) async {
    await _box.put(entry.id, entry);
    await _scheduleNotification(entry);
  }

  @override
  Future<void> update(ScheduleEntry entry) async {
    await _box.put(entry.id, entry);
    await NotificationService.cancel(entry.id.hashCode);
    await _scheduleNotification(entry);
  }

  @override
  Future<void> delete(String id) async {
    await NotificationService.cancel(id.hashCode);
    await _box.delete(id);
  }

  @override
  Stream<List<ScheduleEntry>> watchAll() =>
      _box.watch().map((_) => _box.values.toList());

  Future<void> _scheduleNotification(ScheduleEntry entry) async {
    if (!entry.notifyEnabled) return;
    final timeParts = entry.startTime.split(':');
    final startAt = entry.date.copyWithTime(
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final scheduledAt =
        startAt.subtract(Duration(minutes: entry.notifyMinutesBefore));
    if (scheduledAt.isAfter(DateTime.now())) {
      await NotificationService.scheduleScheduleReminder(
        id: entry.id.hashCode,
        title: '📅 ${entry.title}',
        body: 'Starting in ${entry.notifyMinutesBefore} minutes',
        scheduledAt: scheduledAt,
        payload: entry.id,
      );
    }
  }
}
