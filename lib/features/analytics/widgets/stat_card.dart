import 'package:flutter/material.dart';

import '../../../core/extensions/double_ext.dart';
import '../../../core/enums/expense_category.dart';

/// Stat row for top spending categories.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.rank,
    required this.category,
    required this.amount,
  });

  final int rank;
  final ExpenseCategory category;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text('$rank')),
      title: Text('${category.emoji} ${category.label}'),
      trailing: Text(amount.toCurrency()),
    );
  }
}
