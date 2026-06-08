import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/appointment_status.dart';
import '../../../core/enums/appointment_type.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/utils/app_animations.dart';
import '../../../data/models/appointment.dart';

/// Card tile for an appointment in the list view.
class AppointmentTile extends ConsumerWidget {
  const AppointmentTile({super.key, required this.appointment, this.index = 0});

  final Appointment appointment;
  final int index;

  String _durationLabel() {
    final m = appointment.durationMinutes;
    if (m >= 60) {
      final hours = m ~/ 60;
      final minutes = m % 60;
      return minutes == 0 ? '$hours hr' : '$hours hr $minutes min';
    }
    return '$m min';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = AppointmentType.fromInt(appointment.appointmentType);
    final status = AppointmentStatus.fromInt(appointment.status);
    final isCancelled = status == AppointmentStatus.cancelled;
    final isCompleted = status == AppointmentStatus.completed;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/appointments/${appointment.id}'),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appointment.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(type.icon, color: appointment.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              appointment.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    decoration: isCancelled
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCancelled || isCompleted
                                        ? colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusChip(status: status),
                        ],
                      ),
                      if (appointment.providerName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          appointment.providerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${appointment.time} · ${_durationLabel()}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      if (appointment.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                appointment.location!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!appointment.date.isToday) ...[
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEE, MMM d').format(appointment.date),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).staggerIn(index);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}
