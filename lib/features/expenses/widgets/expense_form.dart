import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String? _imagePath;

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
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: colorScheme.primary),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
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
          // Receipt Photo Section
          Text('Receipt Photo', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Image.file(
                    File(_imagePath!),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: () => setState(() => _imagePath = null),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Change Photo'),
              onPressed: _showImagePickerOptions,
            ),
          ] else
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Attach Receipt Photo'),
              onPressed: _showImagePickerOptions,
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
