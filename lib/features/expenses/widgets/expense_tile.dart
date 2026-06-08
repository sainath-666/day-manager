import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/expense_category.dart';
import '../../../core/utils/app_animations.dart';
import '../../../core/enums/payment_method.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/expense.dart';

/// Expense list tile.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.index = 0});

  final Expense expense;
  final int index;

  @override
  Widget build(BuildContext context) {
    final category = ExpenseCategory.fromInt(expense.category);
    final payment = PaymentMethod.fromInt(expense.paymentMethod);

    return ListTile(
      leading: Hero(
        flightShuttleBuilder: (
          flightContext,
          animation,
          flightDirection,
          fromHeroContext,
          toHeroContext,
        ) {
          return ScaleTransition(
            scale: animation.drive(
              Tween<double>(begin: 0.85, end: 1).chain(
                CurveTween(curve: AppAnimations.bounceCurve),
              ),
            ),
            child: toHeroContext.widget,
          );
        },
        tag: 'expense-emoji-${expense.id}',
        child: Material(
          color: Colors.transparent,
          child: Text(category.emoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
      title: Row(
        children: [
          Expanded(child: Text(expense.description)),
          if (expense.imagePath != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(
                Icons.receipt_long,
                size: 14,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
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
    ).staggerIn(index);
  }
}
