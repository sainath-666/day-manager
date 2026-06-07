import '../models/task.dart';

/// Abstract task repository interface.
abstract class ITaskRepository {
  Future<List<Task>> getAll();
  Future<List<Task>> getByDate(DateTime date);
  Future<Task?> getById(String id);
  Future<void> add(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
  Future<void> toggleComplete(String id);
  Stream<List<Task>> watchAll();
}
