import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/priority.dart';
import '../../../providers/analytics_providers.dart';

/// Upcoming reminders list for the home dashboard.
class UpcomingRemindersSection extends StatelessWidget {
  const UpcomingRemindersSection({super.key, required this.items});

  final List<UpcomingItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.upcomingSection,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSizes.sm),
            ...items.map((item) {
              final color = item.type == 'task'
                  ? Priority.fromInt(item.priority).color
                  : colorScheme.primary;
              return ListTile(
                minLeadingWidth: 20,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 7,
                  backgroundColor: color,
                ),
                title: Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                trailing: Text(
                  item.time,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
