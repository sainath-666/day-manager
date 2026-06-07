import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/extensions/date_time_ext.dart';

/// Tappable field that opens a date picker.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value?.formatDisplay() ?? 'Not set'),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// Tappable field that opens a time picker.
class TimePickerField extends StatelessWidget {
  const TimePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value ?? 'Not set'),
      trailing: const Icon(Icons.access_time),
      onTap: () async {
        final parts = value?.split(':');
        final initial = TimeOfDay(
          hour: int.tryParse(parts?.first ?? '9') ?? 9,
          minute: int.tryParse(parts?.last ?? '0') ?? 0,
        );
        final picked = await showTimePicker(context: context, initialTime: initial);
        if (picked != null) {
          onChanged(
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
          );
        }
      },
    );
  }
}

/// Month selector chip row.
class MonthSelector extends StatelessWidget {
  const MonthSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('MMMM yyyy').format(selected);
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(
            DateTime(selected.year, selected.month - 1),
          ),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onChanged(
            DateTime(selected.year, selected.month + 1),
          ),
        ),
      ],
    );
  }
}
