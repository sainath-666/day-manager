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
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (_, i) {
          final date = startOfWeek.add(Duration(days: i));
          final isSelected = date.isSameDay(selected);
          final isToday = date.isToday;
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () =>
                  ref.read(selectedScheduleDateProvider.notifier).state = date,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
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
                  color: isSelected
                      ? null
                      : (isToday
                          ? colorScheme.primary.withValues(alpha: 0.12)
                          : colorScheme.surfaceContainerLow),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isToday
                            ? colorScheme.primary.withValues(alpha: 0.6)
                            : colorScheme.outlineVariant.withValues(alpha: isDark ? 0.5 : 0.8)),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
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
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isSelected ? Colors.white : colorScheme.onSurface,
                            fontWeight: isToday || isSelected
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                    ),
                    if (isToday) ...[
                      const SizedBox(height: 3),
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
