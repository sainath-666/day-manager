import '../models/schedule_entry.dart';

/// Abstract schedule repository interface.
abstract class IScheduleRepository {
  Future<List<ScheduleEntry>> getAll();
  Future<List<ScheduleEntry>> getByDate(DateTime date);
  Future<ScheduleEntry?> getById(String id);
  Future<void> add(ScheduleEntry entry);
  Future<void> update(ScheduleEntry entry);
  Future<void> delete(String id);
  Stream<List<ScheduleEntry>> watchAll();
}
