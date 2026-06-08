import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/appointment_status.dart';
import '../core/extensions/date_time_ext.dart';
import '../data/models/appointment.dart';
import 'repository_providers.dart';
import 'schedule_providers.dart';

/// Schedule screen tab: 0 = timeline, 1 = appointments.
final scheduleTabIndexProvider = StateProvider<int>((ref) => 0);

/// All appointments notifier.
class AppointmentsNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final repo = ref.watch(appointmentRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Appointment appointment) async {
    await ref.read(appointmentRepositoryProvider).add(appointment);
    ref.invalidateSelf();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await ref.read(appointmentRepositoryProvider).update(appointment);
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await ref.read(appointmentRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final repo = ref.read(appointmentRepositoryProvider);
    final appointment = await repo.getById(id);
    if (appointment == null) return;
    appointment.status = status.value;
    await repo.update(appointment);
    ref.invalidateSelf();
  }
}

final appointmentsNotifierProvider =
    AsyncNotifierProvider<AppointmentsNotifier, List<Appointment>>(
  AppointmentsNotifier.new,
);

/// Appointments for the selected schedule date.
final selectedDayAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final date = ref.watch(selectedScheduleDateProvider);
  final allAsync = ref.watch(appointmentsNotifierProvider);
  return allAsync.when(
    data: (appointments) {
      final dayAppointments =
          appointments.where((a) => a.date.isSameDay(date)).toList()
            ..sort((a, b) => a.time.compareTo(b.time));
      return dayAppointments;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Next upcoming active appointments across all dates.
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final allAsync = ref.watch(appointmentsNotifierProvider);
  final now = DateTime.now();

  return allAsync.when(
    data: (appointments) {
      final upcoming = appointments.where((a) {
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
      return upcoming.take(5).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
