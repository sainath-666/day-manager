import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/enums/priority.dart';
import '../../../data/models/task.dart';
import '../../../shared/widgets/date_time_picker_field.dart';
import 'priority_chip.dart';

/// Form for creating or editing a task.
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    this.task,
    required this.onSave,
  });

  final Task? task;
  final ValueChanged<Task> onSave;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _tagsController;
  DateTime? _dueDate;
  String? _dueTime;
  Priority _priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _tagsController = TextEditingController(text: task?.tags.join(', ') ?? '');
    _dueDate = task?.dueDate;
    _dueTime = task?.dueTime;
    if (task != null) _priority = Priority.fromInt(task.priority);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final tags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (widget.task != null) {
      final task = widget.task!
        ..title = _titleController.text.trim()
        ..description = _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim()
        ..dueDate = _dueDate
        ..dueTime = _dueTime
        ..priority = _priority.value
        ..tags = tags;
      widget.onSave(task);
    } else {
      widget.onSave(Task.create(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        dueDate: _dueDate,
        dueTime: _dueTime,
        priority: _priority.value,
        tags: tags,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: AppStrings.title),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(labelText: AppStrings.description),
            maxLines: 3,
          ),
          DatePickerField(
            label: AppStrings.dueDate,
            value: _dueDate,
            onChanged: (d) => setState(() => _dueDate = d),
          ),
          TimePickerField(
            label: AppStrings.dueTime,
            value: _dueTime,
            onChanged: (t) => setState(() => _dueTime = t),
          ),
          const SizedBox(height: 8),
          Text(AppStrings.priority, style: Theme.of(context).textTheme.labelLarge),
          Wrap(
            spacing: 8,
            children: Priority.values.map((p) {
              return PriorityChip(
                priority: p,
                selected: _priority == p,
                onSelected: (v) => setState(() => _priority = v),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: AppStrings.tags,
              hintText: 'work, health',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
