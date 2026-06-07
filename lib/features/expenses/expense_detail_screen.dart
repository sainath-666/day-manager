import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/enums/expense_category.dart';
import '../../core/enums/payment_method.dart';
import '../../core/extensions/date_time_ext.dart';
import '../../core/extensions/double_ext.dart';
import '../../providers/expense_providers.dart';
import '../../providers/repository_providers.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/expense_form.dart';

/// Expense detail and edit screen.
class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(
      FutureProvider(
        (ref) => ref.watch(expenseRepositoryProvider).getById(expenseId),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.expenses),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await ref.read(expensesNotifierProvider.notifier).delete(expenseId);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      body: expenseAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(height: 300),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (expense) {
          if (expense == null) {
            return const Center(child: Text('Expense not found'));
          }
          final category = ExpenseCategory.fromInt(expense.category);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                expense.amount.toCurrency(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  Hero(
                    tag: 'expense-emoji-${expense.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(category.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category.label, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              Text(PaymentMethod.fromInt(expense.paymentMethod).label),
              Text(expense.date.formatDisplay()),
              const Divider(),
              ExpenseForm(
                expense: expense,
                onSave: (updated) async {
                  await ref
                      .read(expensesNotifierProvider.notifier)
                      .updateExpense(updated);
                  if (context.mounted) context.pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
