import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/expense_category.dart';
import '../../../core/enums/payment_method.dart';
import '../../../data/models/expense.dart';

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
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountController = TextEditingController(
      text: e == null ? '' : e.amount.toStringAsFixed(e.amount.truncateToDouble() == e.amount ? 0 : 2),
    );
    _descController = TextEditingController(text: e?.description ?? '');
    if (e != null) {
      _category = ExpenseCategory.fromInt(e.category);
      _payment = PaymentMethod.fromInt(e.paymentMethod);
      _date = e.date;
      _imagePath = e.imagePath;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerOptions() async {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Receipt photo', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _PickerOption(
                  icon: Icons.camera_alt_outlined,
                  title: 'Take photo',
                  subtitle: 'Use the camera for a new receipt',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
                _PickerOption(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from gallery',
                  subtitle: 'Attach an existing receipt image',
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      setState(() => _imagePath = picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) return;

    if (widget.expense != null) {
      final expense = widget.expense!
        ..amount = amount
        ..category = _category.value
        ..description = _descController.text.trim()
        ..date = _date
        ..paymentMethod = _payment.value
        ..imagePath = _imagePath;
      widget.onSave(expense);
    } else {
      widget.onSave(Expense.create(
        amount: amount,
        category: _category.value,
        description: _descController.text.trim(),
        date: _date,
        paymentMethod: _payment.value,
        imagePath: _imagePath,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fields = <Widget>[
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.receipt_long_outlined, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expense == null ? AppStrings.addExpense : 'Edit Expense',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Track spending with category, date, and receipt.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _descController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: AppStrings.description,
                hintText: 'Lunch, groceries, cab ride',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: AppStrings.amount,
                hintText: '0.00',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                if ((v?.trim() ?? '').isEmpty) return 'Required';
                if (value == null) return 'Enter a valid amount';
                if (value <= 0) return 'Amount must be greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 14),
            const _SectionLabel(label: AppStrings.category),
            const SizedBox(height: 8),
            _SegmentedCard(
              child: DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: ExpenseCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.emoji} ${c.label}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
            ),
            const SizedBox(height: 14),
            const _SectionLabel(label: AppStrings.paymentMethod),
            const SizedBox(height: 8),
            _SegmentedCard(
              child: DropdownButtonFormField<PaymentMethod>(
                initialValue: _payment,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: PaymentMethod.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                    .toList(),
                onChanged: (v) => setState(() => _payment = v ?? _payment),
              ),
            ),
            const SizedBox(height: 14),
            const _SectionLabel(label: AppStrings.date),
            const SizedBox(height: 8),
            _DateCard(
              date: _date,
              onTap: _pickDate,
            ),
            const SizedBox(height: 18),
            const _SectionLabel(label: 'Receipt Photo'),
            const SizedBox(height: 8),
            _ReceiptCard(
              imagePath: _imagePath,
              onAttach: _showImagePickerOptions,
              onRemove: () => setState(() => _imagePath = null),
            ),
            const SizedBox(height: 12),
    ];

    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: fields,
            ),
          );

          if (!constraints.hasBoundedHeight || constraints.maxHeight.isInfinite) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...fields,
                  const SizedBox(height: 10),
                  _SaveButton(onPressed: _submit),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: content),
              const SizedBox(height: 10),
              _SaveButton(onPressed: _submit),
            ],
          );
        },
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: const Icon(Icons.check),
      label: const Text(AppStrings.save),
      onPressed: onPressed,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w900,
          ),
    );
  }
}

class _SegmentedCard extends StatelessWidget {
  const _SegmentedCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(date),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Icon(Icons.edit_calendar_outlined, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({
    required this.imagePath,
    required this.onAttach,
    required this.onRemove,
  });

  final String? imagePath;
  final VoidCallback onAttach;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.file(
              File(imagePath!),
              height: 156,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(999),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: onRemove,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      onTap: onAttach,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attach receipt photo', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Optional, useful for bills and reimbursements',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.add_circle_outline, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
