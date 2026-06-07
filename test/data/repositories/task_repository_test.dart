import 'package:dailyflow/data/models/task.dart';
import 'package:dailyflow/data/repositories/hive_task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Box<Task> box;
  late HiveTaskRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Hive.init('./test_hive_task');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
  });

  setUp(() async {
    box = await Hive.openBox<Task>('tasks_test_${DateTime.now().microsecondsSinceEpoch}');
    repository = HiveTaskRepository(box);
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('add inserts task into getAll', () async {
    final task = Task.create(title: 'Test task');
    await repository.add(task);

    final all = await repository.getAll();
    expect(all.any((t) => t.id == task.id), isTrue);
  });

  test('toggleComplete flips isCompleted and sets completedAt', () async {
    final task = Task.create(title: 'Toggle me');
    await repository.add(task);

    await repository.toggleComplete(task.id);
    final updated = await repository.getById(task.id);
    expect(updated?.isCompleted, isTrue);
    expect(updated?.completedAt, isNotNull);

    await repository.toggleComplete(task.id);
    final reverted = await repository.getById(task.id);
    expect(reverted?.isCompleted, isFalse);
    expect(reverted?.completedAt, isNull);
  });

  test('delete removes task', () async {
    final task = Task.create(title: 'Delete me');
    await repository.add(task);
    await repository.delete(task.id);

    expect(await repository.getById(task.id), isNull);
  });
}
