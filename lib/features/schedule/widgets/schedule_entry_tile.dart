import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/repeat_mode.dart' as app_repeat;
import '../../../data/models/schedule_entry.dart';
import '../../../providers/schedule_providers.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import 'schedule_form.dart';

/// Color-coded schedule entry card for timeline.
class ScheduleEntryTile extends ConsumerWidget {
  const ScheduleEntryTile({super.key, required this.entry});

  final ScheduleEntry entry;

  String _duration() {
    final start = entry.startTime.split(':');
    final end = entry.endTime.split(':');
    final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
    final endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
    final diff = (endMin - startMin).clamp(0, 24 * 60);
    if (diff >= 60) {
      final hours = diff ~/ 60;
      final minutes = diff % 60;
      return minutes == 0 ? '$hours hr' : '$hours hr $minutes min';
    }
    return '$diff min';
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
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
    final repeat = app_repeat.RepeatMode.fromInt(entry.repeatMode);
    final title = entry.title.trim().isEmpty ? 'Scheduled item' : entry.title.trim();
    final notes = entry.notes?.trim();

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
          onTap: () => _showEditSheet(context, ref),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 5,
                  height: 72,
                  decoration: BoxDecoration(
                    color: entry.color,
                    borderRadius: BorderRadius.circular(999),
                  ),
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
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _TimeChip(
                            color: entry.color,
                            label: _duration(),
                          ),
                        ],
                      ),
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
                            '${entry.startTime} - ${entry.endTime}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notes == null || notes.isEmpty ? 'Tap to edit details' : notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (repeat != app_repeat.RepeatMode.none)
                            _MetaPill(icon: Icons.repeat, label: repeat.label),
                          if (entry.notifyEnabled)
                            _MetaPill(
                              icon: Icons.notifications_active_outlined,
                              label: '${entry.notifyMinutesBefore} min before',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
