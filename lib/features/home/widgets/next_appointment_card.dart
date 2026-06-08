import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/appointment_type.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../providers/appointment_providers.dart';

/// Shows the next upcoming appointment on the home dashboard.
class NextAppointmentCard extends ConsumerWidget {
  const NextAppointmentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingAppointmentsProvider);
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;
    final type = AppointmentType.fromInt(next.appointmentType);
    final colorScheme = Theme.of(context).colorScheme;
    final dateLabel = next.date.isToday
        ? 'Today'
        : next.date.isSameDay(DateTime.now().add(const Duration(days: 1)))
            ? 'Tomorrow'
            : DateFormat('EEE, MMM d').format(next.date);

    return Card(
      child: InkWell(
        onTap: () => context.push('/appointments/${next.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: next.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: next.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.nextAppointment,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      next.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      '$dateLabel at ${next.time}'
                      '${next.providerName != null ? ' · ${next.providerName}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
