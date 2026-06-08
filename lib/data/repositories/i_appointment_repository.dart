import '../models/appointment.dart';

/// Abstract appointment repository interface.
abstract class IAppointmentRepository {
  Future<List<Appointment>> getAll();
  Future<List<Appointment>> getByDate(DateTime date);
  Future<List<Appointment>> getUpcoming({int limit = 10});
  Future<Appointment?> getById(String id);
  Future<void> add(Appointment appointment);
  Future<void> update(Appointment appointment);
  Future<void> delete(String id);
  Stream<List<Appointment>> watchAll();
}
