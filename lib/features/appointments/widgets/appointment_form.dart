import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/enums/appointment_status.dart';
import '../../../core/enums/appointment_type.dart';
import '../../../data/models/appointment.dart';
import '../../../shared/widgets/date_time_picker_field.dart';

/// Form widget for creating or editing an appointment.
class AppointmentForm extends StatefulWidget {
  const AppointmentForm({
    super.key,
    this.appointment,
    this.initialDate,
    required this.onSave,
    this.onDelete,
  });

  final Appointment? appointment;
  final DateTime? initialDate;
  final ValueChanged<Appointment> onSave;
  final VoidCallback? onDelete;

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _providerController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late DateTime _date;
  late String _time;
  late AppointmentType _type;
  late AppointmentStatus _status;
  late int _durationMinutes;
  late bool _notifyEnabled;
  late int _notifyMinutesBefore;
  late int _selectedColorValue;

  final List<int> _colorChoices = const [
    0xFF3B82F6,
    0xFF10B981,
    0xFF6750A4,
    0xFFF59E0B,
    0xFFEF4444,
    0xFFEC4899,
    0xFF6B7280,
  ];

  static const _durationChoices = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    final a = widget.appointment;
    _titleController = TextEditingController(text: a?.title ?? '');
    _providerController = TextEditingController(text: a?.providerName ?? '');
    _locationController = TextEditingController(text: a?.location ?? '');
    _notesController = TextEditingController(text: a?.notes ?? '');
    _date = a?.date ?? widget.initialDate ?? DateTime.now();
    _time = a?.time ?? '10:00';
    _type = a != null
        ? AppointmentType.fromInt(a.appointmentType)
        : AppointmentType.medical;
    _status = a != null
        ? AppointmentStatus.fromInt(a.status)
        : AppointmentStatus.scheduled;
    _durationMinutes = a?.durationMinutes ?? 30;
    _notifyEnabled = a?.notifyEnabled ?? true;
    _notifyMinutesBefore = a?.notifyMinutesBefore ?? 30;
    _selectedColorValue = a?.colorValue ?? 0xFF3B82F6;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _providerController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.appointment != null) {
      final updated = widget.appointment!
        ..title = _titleController.text.trim()
        ..providerName = _providerController.text.trim().isEmpty
            ? null
            : _providerController.text.trim()
        ..location = _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim()
        ..appointmentType = _type.value
        ..date = _date
        ..time = _time
        ..durationMinutes = _durationMinutes
        ..status = _status.value
        ..notes = _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()
        ..notifyEnabled = _notifyEnabled
        ..notifyMinutesBefore = _notifyMinutesBefore
        ..colorValue = _selectedColorValue;
      widget.onSave(updated);
    } else {
      widget.onSave(Appointment.create(
        title: _titleController.text.trim(),
        providerName: _providerController.text.trim().isEmpty
            ? null
            : _providerController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        appointmentType: _type.value,
        date: _date,
        time: _time,
        durationMinutes: _durationMinutes,
        status: _status.value,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
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
                widget.appointment == null
                    ? AppStrings.addAppointment
                    : AppStrings.editAppointment,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (widget.appointment != null && widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: colorScheme.error,
                  tooltip: AppStrings.delete,
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
            controller: _providerController,
            decoration: const InputDecoration(
              labelText: AppStrings.providerName,
              hintText: 'e.g. Dr. Smith',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: AppStrings.location,
              hintText: 'e.g. City Medical Center',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AppointmentType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: AppStrings.appointmentType),
            items: AppointmentType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          Icon(t.icon, size: 18),
                          const SizedBox(width: 8),
                          Text(t.label),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 12),
          DatePickerField(
            label: AppStrings.date,
            value: _date,
            onChanged: (v) => setState(() => _date = v ?? _date),
          ),
          const SizedBox(height: 12),
          TimePickerField(
            label: AppStrings.appointmentTime,
            value: _time,
            onChanged: (v) => setState(() => _time = v ?? _time),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _durationMinutes,
            decoration: const InputDecoration(labelText: AppStrings.duration),
            items: _durationChoices
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m >= 60 ? '${m ~/ 60} hr' : '$m min'),
                    ))
                .toList(),
            onChanged: (v) =>
                setState(() => _durationMinutes = v ?? _durationMinutes),
          ),
          if (widget.appointment != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<AppointmentStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: AppStrings.status),
              items: AppointmentStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(s.icon, size: 18, color: s.color),
                            const SizedBox(width: 8),
                            Text(s.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _status = v ?? _status),
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes (Optional)'),
            maxLines: 2,
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
              decoration: const InputDecoration(labelText: AppStrings.notifyBefore),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15 minutes before')),
                DropdownMenuItem(value: 30, child: Text('30 minutes before')),
                DropdownMenuItem(value: 60, child: Text('1 hour before')),
                DropdownMenuItem(value: 120, child: Text('2 hours before')),
                DropdownMenuItem(value: 1440, child: Text('1 day before')),
              ],
              onChanged: (v) =>
                  setState(() => _notifyMinutesBefore = v ?? _notifyMinutesBefore),
            ),
            const SizedBox(height: 12),
          ],
          Text('Color', style: Theme.of(context).textTheme.titleSmall),
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
