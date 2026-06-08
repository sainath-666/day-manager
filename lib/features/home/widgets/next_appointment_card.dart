import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/appointment_type.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/utils/app_animations.dart';
import '../../../providers/appointment_providers.dart';
import '../../../shared/widgets/scale_tap.dart';

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

    return ScaleTap(
      onTap: () => context.push('/appointments/${next.id}'),
      child: Card(
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
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 1600.ms,
                    curve: Curves.easeInOut,
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
    )
        .animate()
        .fadeIn(duration: AppAnimations.normal)
        .slideX(begin: -0.04, end: 0, duration: AppAnimations.slow, curve: AppAnimations.enterCurve);
  }
}
