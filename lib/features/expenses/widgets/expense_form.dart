import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/enums/expense_category.dart';
import '../../../core/enums/payment_method.dart';
import '../../../data/models/expense.dart';
import '../../../shared/widgets/date_time_picker_field.dart';

/// Form for creating or editing an expense.
class ExpenseForm extends StatefulWidget {
  const ExpenseForm({
    super.key,
    this.expense,
    required this.onSave,
  });

  final Expense? expense;
  final ValueChanged<Expense> onSave;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descController;
  ExpenseCategory _category = ExpenseCategory.other;
  PaymentMethod _payment = PaymentMethod.cash;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController = TextEditingController(
      text: e?.amount.toString() ?? '',
    );
    _descController = TextEditingController(text: e?.description ?? '');
    if (e != null) {
      _category = ExpenseCategory.fromInt(e.category);
      _payment = PaymentMethod.fromInt(e.paymentMethod);
      _date = e.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    if (widget.expense != null) {
      final expense = widget.expense!
        ..amount = amount
        ..category = _category.value
        ..description = _descController.text.trim()
        ..date = _date
        ..paymentMethod = _payment.value;
      widget.onSave(expense);
    } else {
      widget.onSave(Expense.create(
        amount: amount,
        category: _category.value,
        description: _descController.text.trim(),
        date: _date,
        paymentMethod: _payment.value,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(labelText: AppStrings.description),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: AppStrings.amount),
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (double.tryParse(v) == null) return 'Invalid amount';
              return null;
            },
          ),
          DropdownButtonFormField<ExpenseCategory>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: AppStrings.category),
            items: ExpenseCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.emoji} ${c.label}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          DropdownButtonFormField<PaymentMethod>(
            initialValue: _payment,
            decoration:
                const InputDecoration(labelText: AppStrings.paymentMethod),
            items: PaymentMethod.values
                .map((m) =>
                    DropdownMenuItem(value: m, child: Text(m.label)))
                .toList(),
            onChanged: (v) => setState(() => _payment = v ?? _payment),
          ),
          DatePickerField(
            label: AppStrings.date,
            value: _date,
            onChanged: (d) => setState(() => _date = d ?? _date),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
