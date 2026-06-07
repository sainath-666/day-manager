import 'package:dailyflow/data/models/task.dart';
import 'package:dailyflow/features/tasks/widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TaskTile shows title and due time', (tester) async {
    final task = Task.create(
      title: 'Morning workout',
      dueDate: DateTime.now(),
      dueTime: '07:00',
      priority: 1,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: TaskTile(task: task)),
        ),
      ),
    );

    expect(find.text('Morning workout'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);
  });
}
