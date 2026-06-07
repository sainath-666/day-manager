import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/date_time_ext.dart';
import '../../../providers/schedule_providers.dart';

/// Horizontal week day selector strip.
class WeekStrip extends ConsumerWidget {
  const WeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedScheduleDateProvider);
    final startOfWeek = selected.subtract(Duration(days: selected.weekday - 1));

    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final date = startOfWeek.add(Duration(days: i));
          final isSelected = date.isSameDay(selected);
          final isToday = date.isToday;
          final colorScheme = Theme.of(context).colorScheme;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () =>
                  ref.read(selectedScheduleDateProvider.notifier).state = date,
              child: Container(
                width: 56,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isSelected && isToday
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isToday
                            ? colorScheme.primary.withValues(alpha: 0.5)
                            : colorScheme.outlineVariant.withValues(alpha: 0.35)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date).toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? Colors.white : colorScheme.onSurface,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w900
                                : FontWeight.normal,
                          ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.white : colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
