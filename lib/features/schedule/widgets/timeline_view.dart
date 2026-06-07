import 'package:flutter/material.dart';

import '../../../data/models/schedule_entry.dart';
import 'schedule_entry_tile.dart';

/// Vertical timeline view for a day's schedule.
class TimelineView extends StatelessWidget {
  const TimelineView({super.key, required this.entries});

  final List<ScheduleEntry> entries;

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(15, (i) => i + 7);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 16, 132),
      itemCount: hours.length,
      itemBuilder: (_, i) {
        final hour = hours[i];
        final hourStr = '${hour.toString().padLeft(2, '0')}:00';
        final hourEntries = entries.where((e) {
          final startHour = int.tryParse(e.startTime.split(':').first) ?? -1;
          return startHour == hour;
        }).toList();

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  hourStr,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: hourEntries.isEmpty
                      ? _OpenSlot(hour: hour)
                      : Column(
                          children: hourEntries
                              .map((entry) => ScheduleEntryTile(entry: entry))
                              .toList(),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OpenSlot extends StatelessWidget {
  const _OpenSlot({required this.hour});

  final int hour;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWorkBlock = hour >= 9 && hour <= 17;

    return Container(
      height: 42,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 12),
      child: isWorkBlock
          ? Container(
              width: 86,
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.8),
            )
          : null,
    );
  }
}
