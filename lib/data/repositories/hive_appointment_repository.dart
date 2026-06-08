import 'package:hive/hive.dart';

import '../../core/enums/appointment_status.dart';
import '../../core/extensions/date_time_ext.dart';
import '../../core/utils/notification_service.dart';
import '../models/appointment.dart';
import 'i_appointment_repository.dart';

/// Hive-backed appointment repository with notification scheduling.
class HiveAppointmentRepository implements IAppointmentRepository {
  HiveAppointmentRepository(this._box);

  final Box<Appointment> _box;

  @override
  Future<List<Appointment>> getAll() async => _box.values.toList();

  @override
  Future<List<Appointment>> getByDate(DateTime date) async =>
      _box.values.where((a) => a.date.isSameDay(date)).toList();

  @override
  Future<List<Appointment>> getUpcoming({int limit = 10}) async {
    final now = DateTime.now();
    final active = _box.values.where((a) {
      final status = AppointmentStatus.fromInt(a.status);
      if (!status.isActive) return false;
      final timeParts = a.time.split(':');
      final at = a.date.copyWithTime(
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      return at.isAfter(now) || at.isSameDay(now);
    }).toList()
      ..sort((a, b) {
        final aParts = a.time.split(':');
        final bParts = b.time.split(':');
        final aAt = a.date.copyWithTime(
          int.parse(aParts[0]),
          int.parse(aParts[1]),
        );
        final bAt = b.date.copyWithTime(
          int.parse(bParts[0]),
          int.parse(bParts[1]),
        );
        return aAt.compareTo(bAt);
      });
    return active.take(limit).toList();
  }

  @override
  Future<Appointment?> getById(String id) async => _box.get(id);

  @override
  Future<void> add(Appointment appointment) async {
    await _box.put(appointment.id, appointment);
    await _scheduleNotification(appointment);
  }

  @override
  Future<void> update(Appointment appointment) async {
    await _box.put(appointment.id, appointment);
    await NotificationService.cancel(appointment.id.hashCode);
    await _scheduleNotification(appointment);
  }

  @override
  Future<void> delete(String id) async {
    await NotificationService.cancel(id.hashCode);
    await _box.delete(id);
  }

  @override
  Stream<List<Appointment>> watchAll() =>
      _box.watch().map((_) => _box.values.toList());

  Future<void> _scheduleNotification(Appointment appointment) async {
    final status = AppointmentStatus.fromInt(appointment.status);
    if (!appointment.notifyEnabled || !status.isActive) return;

    final timeParts = appointment.time.split(':');
    final at = appointment.date.copyWithTime(
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
    final scheduledAt =
        at.subtract(Duration(minutes: appointment.notifyMinutesBefore));
    if (scheduledAt.isAfter(DateTime.now())) {
      await NotificationService.scheduleAppointmentReminder(
        id: appointment.id.hashCode,
        title: '📋 ${appointment.title}',
        body: 'In ${appointment.notifyMinutesBefore} minutes'
            '${appointment.providerName != null ? ' with ${appointment.providerName}' : ''}',
        scheduledAt: scheduledAt,
        payload: appointment.id,
      );
    }
  }
}
