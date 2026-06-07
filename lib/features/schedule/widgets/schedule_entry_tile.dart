import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/schedule_entry.dart';
import '../../../providers/schedule_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import 'schedule_form.dart';

/// Color-coded schedule entry pill for timeline.
class ScheduleEntryTile extends ConsumerWidget {
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

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: ScheduleForm(
          entry: entry,
          onSave: (updated) async {
            await ref.read(scheduleNotifierProvider.notifier).updateEntry(updated);
            if (ctx.mounted) Navigator.pop(ctx);
          },
          onDelete: () async {
            final confirm = await showConfirmDialog(
              context,
              title: 'Delete Schedule Entry',
              message: 'Are you sure you want to delete "${entry.title}"?',
            );
            if (confirm == true) {
              await ref.read(scheduleNotifierProvider.notifier).delete(entry.id);
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: entry.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: entry.color, width: 4)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditSheet(context, ref),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (entry.notes != null && entry.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            entry.notes!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _duration(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${entry.startTime} - ${entry.endTime}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}
