import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/expense_category.dart';
import '../../../core/enums/payment_method.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/expense.dart';

/// Expense list tile.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.fromInt(expense.category);
    final payment = PaymentMethod.fromInt(expense.paymentMethod);

    return ListTile(
      leading: Hero(
        tag: 'expense-emoji-${expense.id}',
        child: Material(
          color: Colors.transparent,
          child: Text(category.emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
      title: Text(expense.description),
      subtitle: Text(category.label),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(expense.amount.toCurrency()),
          Text(payment.label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      onTap: () => context.push('/expenses/${expense.id}'),
    );
  }
}
