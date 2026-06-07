import 'package:flutter/material.dart';

import '../../../core/enums/expense_category.dart';

/// Category display chip with emoji.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.compact = false,
  });

  final ExpenseCategory category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Text(category.emoji),
      label: Text(compact ? category.label : '${category.label} ${category.emoji}'),
      backgroundColor: category.color.withValues(alpha: 0.15),
    );
  }
}
