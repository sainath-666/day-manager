import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_strings.dart';
import '../../core/enums/expense_category.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_providers.dart';
import 'widgets/bill_note_form.dart';

/// Screen representing the Bill Scanner (Phase 2: visually polished OCR simulation).
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

  // Scanning simulation state
  bool _isScanning = false;
  final List<String> _scanLogs = [];
  double _scanProgress = 0.0;
  Timer? _logTimer;

  // Preset receipts for testing simulation
  final List<_MockReceiptPreset> _presets = const [
    _MockReceiptPreset(
      name: 'Starbucks Coffee Receipt',
      description: 'Starbucks Coffee',
      amount: 320.00,
      category: ExpenseCategory.food,
      note: 'Store #4512 · Latte + Croissant',
    ),
    _MockReceiptPreset(
      name: 'Uber Taxi Receipt',
      description: 'Uber Ride',
      amount: 2200.00,
      category: ExpenseCategory.transport,
      note: 'Ride to corporate office split',
    ),
    _MockReceiptPreset(
      name: 'Walmart Grocery Invoice',
      description: 'Walmart Supercenter',
      amount: 850.00,
      category: ExpenseCategory.groceries,
      note: 'Weekly grocery refill: bread, milk, eggs',
    ),
    _MockReceiptPreset(
      name: 'Electric Power Bill',
      description: 'State Power Supply',
      amount: 3500.00,
      category: ExpenseCategory.utilities,
      note: 'Electricity consumption bill for May 2026',
    ),
  ];

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _logTimer?.cancel();
    super.dispose();
  }

  void _startScanningSimulation(_MockReceiptPreset preset) {
    setState(() {
      _isScanning = true;
      _scanProgress = 0.0;
      _scanLogs.clear();
      _scanLogs.add('⚡ Initializing OCR engine...');
    });

    const steps = [
      '📁 Reading image structure...',
      '🔍 Identifying text boundary coordinates...',
      '📝 Recognizing characters via Local NN...',
      '💰 Extracting numerical transaction values...',
      '🏷️ Mapping entities to category classifiers...',
      '✅ Scanning Complete!',
    ];

    int currentStep = 0;
    _logTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (currentStep < steps.length) {
        setState(() {
          _scanLogs.add(steps[currentStep]);
          _scanProgress = (currentStep + 1) / steps.length;
        });
        currentStep++;
      } else {
        timer.cancel();
        setState(() {
          _isScanning = false;
          _descController.text = preset.description;
          _amountController.text = preset.amount.toString();
          _category = preset.category;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Autofilled: ${preset.description} - ₹${preset.amount}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));

    // Choose a random preset or create a dynamic mock based on image properties
    final preset = (_presets..shuffle()).first;
    _startScanningSimulation(preset);
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.scanBill)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Smart OCR Scanner',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan paper receipts using local intelligence to extract amount, categories, and tags automatically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          // Actions
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
          const SizedBox(height: 20),

          // Presets / Quick Test section
          if (!_isScanning && _pickedImage == null) ...[
            Text(
              'Quick Demo Templates',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._presets.map((preset) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 0,
                  color: colorScheme.surfaceContainerLow,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: preset.category.color.withValues(alpha: 0.15),
                      child: Text(preset.category.emoji),
                    ),
                    title: Text(preset.name),
                    subtitle: Text('₹${preset.amount} · ${preset.description}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      _startScanningSimulation(preset);
                    },
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Scanning Animation Overlay & Terminal Log
          if (_isScanning) ...[
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Laser Line scanning animation
                  Positioned.fill(
                    child: Container(
                      color: Colors.black87,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: CustomPaint(
                              painter: _GridPainter(gridColor: colorScheme.primary.withValues(alpha: 0.12)),
                            ),
                          ),
                          // Running terminal log
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                        children: [
                                          CircleAvatar(radius: 4, backgroundColor: Colors.red),
                                          SizedBox(width: 4),
                                          CircleAvatar(radius: 4, backgroundColor: Colors.yellow),
                                          SizedBox(width: 4),
                                          CircleAvatar(radius: 4, backgroundColor: Colors.green),
                                        ],
                                      ),
                                      Text(
                                        'LIVE SCANNER',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.white24),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _scanLogs.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Text(
                                            _scanLogs[index],
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Animated laser line
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary,
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(
                        begin: 0,
                        end: 236,
                        duration: 1200.ms,
                        curve: Curves.easeInOutSine,
                      ),
                  // Progress indicator
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: _scanProgress,
                      color: colorScheme.primary,
                      backgroundColor: Colors.white12,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_pickedImage != null && !_isScanning) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],

          // Form details
          if (!_isScanning) ...[
            BillNoteForm(
              descController: _descController,
              amountController: _amountController,
              category: _category,
              date: _date,
              onCategoryChanged: (c) => setState(() => _category = c),
              onDateChanged: (d) => setState(() => _date = d ?? _date),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveExpense,
              child: const Text(AppStrings.saveAsExpense),
            ),
          ],
        ],
      ),
    );
  }
}

class _MockReceiptPreset {
  const _MockReceiptPreset({
    required this.name,
    required this.description,
    required this.amount,
    required this.category,
    required this.note,
  });

  final String name;
  final String description;
  final double amount;
  final ExpenseCategory category;
  final String note;
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.gridColor});

  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
