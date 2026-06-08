import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/appointment.dart';
import 'appointment_tile.dart';

/// Scrollable list of appointments for a selected day.
class AppointmentsListView extends StatelessWidget {
  const AppointmentsListView({super.key, required this.appointments});

  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: appointments.length,
      itemBuilder: (_, i) => AppointmentTile(appointment: appointments[i]),
    );
  }
}

/// Summary header for appointments on the selected day.
class AppointmentsDaySummary extends StatelessWidget {
  const AppointmentsDaySummary({
    super.key,
    required this.selectedDate,
    required this.appointments,
  });

  final DateTime selectedDate;
  final List<Appointment> appointments;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeCount = appointments.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.event_note_outlined, color: colorScheme.tertiary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appointments,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeCount == 0
                        ? AppStrings.noAppointments
                        : '$activeCount appointment${activeCount == 1 ? '' : 's'} scheduled',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
