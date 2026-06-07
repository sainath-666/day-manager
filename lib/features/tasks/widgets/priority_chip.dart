import 'package:flutter/material.dart';

import '../../../core/enums/priority.dart';

/// Priority indicator dot or chip.
class PriorityIndicator extends StatelessWidget {
  const PriorityIndicator({super.key, required this.priority});

  final int priority;

  @override
  Widget build(BuildContext context) {
    final p = Priority.fromInt(priority);
    return Semantics(
      label: '${p.label} priority',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: p.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Priority selection chip.
class PriorityChip extends StatelessWidget {
  const PriorityChip({
    super.key,
    required this.priority,
    required this.selected,
    required this.onSelected,
  });

  final Priority priority;
  final bool selected;
  final ValueChanged<Priority> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(priority.label),
      selected: selected,
      onSelected: (_) => onSelected(priority),
      avatar: CircleAvatar(backgroundColor: priority.color, radius: 6),
    );
  }
}
