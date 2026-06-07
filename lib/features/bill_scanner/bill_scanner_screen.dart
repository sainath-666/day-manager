import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/feature_flags.dart';
import '../../core/enums/expense_category.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_providers.dart';
import 'widgets/bill_note_form.dart';

/// Bill scanner screen (Phase 1: manual entry, image pick only).
class BillScannerScreen extends ConsumerStatefulWidget {
  const BillScannerScreen({super.key});

  @override
  ConsumerState<BillScannerScreen> createState() => _BillScannerScreenState();
}

class _BillScannerScreenState extends ConsumerState<BillScannerScreen> {
  File? _pickedImage;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));

    if (kOcrEnabled) {
      // Phase 2: ML Kit OCR integration
    }
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.fillRequired)),
      );
      return;
    }
    final expense = Expense.create(
      amount: amount,
      category: _category.value,
      description: _descController.text.trim(),
      date: _date,
      imagePath: _pickedImage?.path,
    );
    await ref.read(expensesNotifierProvider.notifier).add(expense);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scanBill)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(AppStrings.takePhoto),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text(AppStrings.pickGallery),
                ),
              ),
            ],
          ),
          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 120, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 16),
          BillNoteForm(
            descController: _descController,
            amountController: _amountController,
            category: _category,
            date: _date,
            onCategoryChanged: (c) => setState(() => _category = c),
            onDateChanged: (d) => setState(() => _date = d ?? _date),
          ),
          if (!kOcrEnabled) ...[
            const SizedBox(height: 12),
            Text(
              'ℹ️ ${AppStrings.ocrHint}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saveExpense,
            child: const Text(AppStrings.saveAsExpense),
          ),
        ],
      ),
    );
  }
}
