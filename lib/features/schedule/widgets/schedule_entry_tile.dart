import 'package:flutter/material.dart';

import '../../../data/models/schedule_entry.dart';

/// Color-coded schedule entry pill for timeline.
class ScheduleEntryTile extends StatelessWidget {
  const ScheduleEntryTile({super.key, required this.entry});

  final ScheduleEntry entry;

  String _duration() {
    final start = entry.startTime.split(':');
    final end = entry.endTime.split(':');
    final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
    final endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
    final diff = endMin - startMin;
    if (diff >= 60) return '${diff ~/ 60} hr';
    return '$diff min';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: entry.color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Text(_duration(), style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
