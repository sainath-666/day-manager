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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  ref.read(selectedScheduleDateProvider.notifier).state = date,
              child: Container(
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE').format(date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      '${date.day}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
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
