import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/app_animations.dart';
import '../../core/enums/expense_category.dart';
import '../../core/enums/payment_method.dart';
import '../../core/extensions/date_time_ext.dart';
import '../../data/models/expense.dart';
import '../../providers/expense_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/date_time_picker_field.dart';
import 'widgets/expense_form.dart';
import 'widgets/expense_tile.dart';
import 'widgets/month_summary_card.dart';

/// Expenses list grouped by date with monthly summary, search, filter, and CSV export.
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  // Search & Filter State
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  ExpenseCategory? _filterCategory;
  PaymentMethod? _filterPaymentMethod;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSheet() {
    AppAnimations.showBottomSheet(
      context: context,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ExpenseForm(
          onSave: (expense) async {
            await ref.read(expensesNotifierProvider.notifier).add(expense);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Expenses',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterCategory = null;
                              _filterPaymentMethod = null;
                            });
                            setSheetState(() {});
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Category', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ExpenseCategory.values.map((c) {
                          final selected = _filterCategory == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text('${c.emoji} ${c.label}'),
                              selected: selected,
                              onSelected: (val) {
                                setState(() {
                                  _filterCategory = val ? c : null;
                                });
                                setSheetState(() {});
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Payment Method', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: PaymentMethod.values.map((m) {
                        final selected = _filterPaymentMethod == m;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(m.label),
                            selected: selected,
                            onSelected: (val) {
                              setState(() {
                                _filterPaymentMethod = val ? m : null;
                              });
                              setSheetState(() {});
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _exportToCsv(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export')),
      );
      return;
    }

    final buffer = StringBuffer('Date,Description,Category,Amount,Payment Method,Receipt Note\n');
    for (final e in expenses) {
      final category = ExpenseCategory.fromInt(e.category).label;
      final payment = PaymentMethod.fromInt(e.paymentMethod).label;
      final dateStr = DateFormat('yyyy-MM-dd').format(e.date);
      final desc = e.description.replaceAll('"', '""');
      final note = (e.receiptNote ?? '').replaceAll('"', '""');
      buffer.writeln('$dateStr,"$desc",$category,${e.amount},$payment,"$note"');
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/expenses_export.csv');
      await file.writeAsString(buffer.toString());
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'DailyFlow Expenses CSV Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }

  List<Expense> _applySearchAndFilter(List<Expense> expenses) {
    var list = List<Expense>.from(expenses);

    // Apply search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((e) => e.description.toLowerCase().contains(query)).toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      list = list.where((e) => e.category == _filterCategory!.value).toList();
    }

    // Apply payment method filter
    if (_filterPaymentMethod != null) {
      list = list.where((e) => e.paymentMethod == _filterPaymentMethod!.value).toList();
    }

    return list;
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final map = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = e.date.formatRelative();
      map.putIfAbsent(key, () => []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesNotifierProvider);
    final monthExpenses = ref.watch(monthExpensesProvider);
    final selectedMonth = ref.watch(selectedExpenseMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              )
            : const Text(AppStrings.expenses),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                  });
                },
              )
            : null,
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => _searchController.clear(),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
          IconButton(
            icon: Icon(
              _filterCategory != null || _filterPaymentMethod != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
              color: _filterCategory != null || _filterPaymentMethod != null
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export CSV',
            onPressed: () => _exportToCsv(monthExpenses),
          ),
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: () => context.push('/scan'),
            tooltip: AppStrings.scanBill,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(expensesNotifierProvider),
        ),
        data: (_) {
          final filteredExpenses = _applySearchAndFilter(monthExpenses);
          final total = filteredExpenses.fold<double>(0, (s, e) => s + e.amount);
          final grouped = _groupByDate(filteredExpenses);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: MonthSelector(
                  selected: selectedMonth,
                  onChanged: (m) =>
                      ref.read(selectedExpenseMonthProvider.notifier).state = m,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MonthSummaryCard(total: total),
              ),
              Expanded(
                child: filteredExpenses.isEmpty
                    ? const EmptyState(message: AppStrings.noExpenses)
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 132),
                        children: () {
                          var index = 0;
                          return grouped.entries.expand((entry) {
                            final section = <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ).staggerIn(index++),
                              ),
                              ...entry.value.map(
                                (e) => ExpenseTile(expense: e, index: index++),
                              ),
                            ];
                            return section;
                          }).toList();
                        }(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
