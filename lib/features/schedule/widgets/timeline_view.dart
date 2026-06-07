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

    return ListView.builder(
      itemCount: hours.length,
      itemBuilder: (_, i) {
        final hour = hours[i];
        final hourStr = '${hour.toString().padLeft(2, '0')}:00';
        final hourEntries = entries.where((e) {
          final startHour = int.parse(e.startTime.split(':')[0]);
          return startHour == hour;
        }).toList();

        return SizedBox(
          height: hourEntries.isEmpty ? 48 : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  hourStr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Column(
                  children: hourEntries
                      .map((e) => ScheduleEntryTile(entry: e))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
