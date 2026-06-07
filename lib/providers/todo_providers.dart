import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Notifier that manages the standalone Quick Todos checklist stored in Hive.
class TodosNotifier extends Notifier<List<Map<String, dynamic>>> {
  Box get _box => Hive.box('todos');

  @override
  List<Map<String, dynamic>> build() {
    final list = _box.values.toList();
    return list.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList()
      ..sort((a, b) => (a['createdAt'] as String).compareTo(b['createdAt'] as String));
  }

  void addTodo(String title) {
    if (title.trim().isEmpty) return;
    
    final id = const Uuid().v4();
    final todo = {
      'id': id,
      'title': title.trim(),
      'isCompleted': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    _box.put(id, todo);
    state = [...state, todo];
  }

  void toggleTodo(String id) {
    final index = state.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(state[index]);
      updated['isCompleted'] = !(updated['isCompleted'] as bool);
      
      _box.put(id, updated);
      state = [
        for (var i = 0; i < state.length; i++)
          if (i == index) updated else state[i]
      ];
    }
  }

  void deleteTodo(String id) {
    _box.delete(id);
    state = state.where((t) => t['id'] != id).toList();
  }
}

/// Provider for the quick todos list.
final todosProvider = NotifierProvider<TodosNotifier, List<Map<String, dynamic>>>(TodosNotifier.new);

/// Provider for the completion rate of the quick todos (0.0–1.0).
final todosCompletionRateProvider = Provider<double>((ref) {
  final todos = ref.watch(todosProvider);
  if (todos.isEmpty) return 0.0;
  final completed = todos.where((t) => t['isCompleted'] == true).length;
  return completed / todos.length;
});
