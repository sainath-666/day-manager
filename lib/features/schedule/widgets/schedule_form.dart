import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/repeat_mode.dart' as app_repeat;
import '../../../data/models/schedule_entry.dart';
import '../../../shared/widgets/date_time_picker_field.dart';

/// Form widget for creating or editing a schedule entry.
class ScheduleForm extends StatefulWidget {
  const ScheduleForm({
    super.key,
    this.entry,
    required this.onSave,
    this.onDelete,
  });

  final ScheduleEntry? entry;
  final ValueChanged<ScheduleEntry> onSave;
  final VoidCallback? onDelete;

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late String _startTime;
  late String _endTime;
  late app_repeat.RepeatMode _repeatMode;
  late bool _notifyEnabled;
  late int _notifyMinutesBefore;
  late int _selectedColorValue;

  final List<int> _colorChoices = const [
    0xFF6750A4, // Theme Default / Purple
    0xFF3B82F6, // Blue
    0xFF10B981, // Emerald
    0xFFF59E0B, // Amber
    0xFFEF4444, // Red
    0xFFEC4899, // Pink
    0xFF6B7280, // Grey
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleController = TextEditingController(text: e?.title ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _startTime = e?.startTime ?? '09:00';
    _endTime = e?.endTime ?? '10:00';
    _repeatMode = e != null ? app_repeat.RepeatMode.fromInt(e.repeatMode) : app_repeat.RepeatMode.none;
    _notifyEnabled = e?.notifyEnabled ?? true;
    _notifyMinutesBefore = e?.notifyMinutesBefore ?? 10;
    _selectedColorValue = e?.colorValue ?? 0xFF6750A4;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateTimes() {
    final startParts = _startTime.split(':');
    final endParts = _endTime.split(':');
    final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return startMin < endMin;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateTimes()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start time must be before end time')),
      );
      return;
    }

    if (widget.entry != null) {
      final updated = widget.entry!
        ..title = _titleController.text.trim()
        ..notes = _notesController.text.trim()
        ..startTime = _startTime
        ..endTime = _endTime
        ..repeatMode = _repeatMode.value
        ..notifyEnabled = _notifyEnabled
        ..notifyMinutesBefore = _notifyMinutesBefore
        ..colorValue = _selectedColorValue;
      widget.onSave(updated);
    } else {
      widget.onSave(ScheduleEntry.create(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        date: widget.entry?.date ?? DateTime.now(),
        startTime: _startTime,
        endTime: _endTime,
        repeatMode: _repeatMode.value,
        notifyEnabled: _notifyEnabled,
        notifyMinutesBefore: _notifyMinutesBefore,
        colorValue: _selectedColorValue,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.entry == null ? AppStrings.addSchedule : 'Edit Schedule Entry',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (widget.entry != null && widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: colorScheme.error,
                  tooltip: 'Delete Entry',
                  onPressed: widget.onDelete,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: AppStrings.title),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (Optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TimePickerField(
                  label: AppStrings.startTime,
                  value: _startTime,
                  onChanged: (v) => setState(() => _startTime = v ?? _startTime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TimePickerField(
                  label: AppStrings.endTime,
                  value: _endTime,
                  onChanged: (v) => setState(() => _endTime = v ?? _endTime),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<app_repeat.RepeatMode>(
            initialValue: _repeatMode,
            decoration: const InputDecoration(labelText: AppStrings.repeat),
            items: app_repeat.RepeatMode.values
                .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) => setState(() => _repeatMode = v ?? _repeatMode),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.notifications),
            value: _notifyEnabled,
            onChanged: (v) => setState(() => _notifyEnabled = v),
          ),
          if (_notifyEnabled) ...[
            DropdownButtonFormField<int>(
              initialValue: _notifyMinutesBefore,
              decoration: const InputDecoration(labelText: 'Remind Before'),
              items: const [
                DropdownMenuItem(value: 5, child: Text('5 minutes before')),
                DropdownMenuItem(value: 10, child: Text('10 minutes before')),
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
              ],
              onChanged: (v) => setState(() => _notifyMinutesBefore = v ?? _notifyMinutesBefore),
            ),
            const SizedBox(height: 12),
          ],
          Text('Color Label', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: _colorChoices.map((cVal) {
              final color = Color(cVal);
              final selected = _selectedColorValue == cVal;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = cVal),
                  child: CircleAvatar(
                    radius: selected ? 20 : 16,
                    backgroundColor: color,
                    child: selected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
              );
            }).toList(),
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
