import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/enums/expense_category.dart';
import '../../../shared/widgets/date_time_picker_field.dart';

/// Manual bill entry form fields.
class BillNoteForm extends StatelessWidget {
  const BillNoteForm({
    super.key,
    required this.descController,
    required this.amountController,
    required this.category,
    required this.date,
    required this.onCategoryChanged,
    required this.onDateChanged,
  });

  final TextEditingController descController;
  final TextEditingController amountController;
  final ExpenseCategory category;
  final DateTime date;
  final ValueChanged<ExpenseCategory> onCategoryChanged;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.billDetails,
                style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: AppStrings.description),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: AppStrings.amount),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: category,
              decoration: const InputDecoration(labelText: AppStrings.category),
              items: ExpenseCategory.values
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.emoji} ${c.label}'),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onCategoryChanged(v);
              },
            ),
            DatePickerField(
              label: AppStrings.date,
              value: date,
              onChanged: onDateChanged,
            ),
          ],
        ),
      ),
    );
  }
}
