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
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.upcomingSection,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSizes.sm),
        ...items.map((item) {
          final color = item.type == 'task'
              ? Priority.fromInt(item.priority).color
              : Theme.of(context).colorScheme.primary;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 6,
              backgroundColor: color,
            ),
            title: Text(item.title),
            trailing: Text(item.time),
          );
        }),
      ],
    );
  }
}
