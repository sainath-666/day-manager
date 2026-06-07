import 'package:flutter/material.dart';

/// Expense categories with display metadata.
enum ExpenseCategory {
  food(0, 'Food', '🍔', Color(0xFFE53935)),
  fuel(1, 'Fuel', '⛽', Color(0xFF6D4C41)),
  groceries(2, 'Groceries', '🛒', Color(0xFF43A047)),
  utilities(3, 'Utilities', '⚡', Color(0xFF1E88E5)),
  transport(4, 'Transport', '🚗', Color(0xFF8E24AA)),
  health(5, 'Health', '💊', Color(0xFF00ACC1)),
  entertainment(6, 'Entertainment', '🎬', Color(0xFFFB8C00)),
  shopping(7, 'Shopping', '🛍️', Color(0xFF3949AB)),
  other(8, 'Other', '📦', Color(0xFF757575));

  const ExpenseCategory(this.value, this.label, this.emoji, this.color);

  final int value;
  final String label;
  final String emoji;
  final Color color;

  static ExpenseCategory fromInt(int value) => ExpenseCategory.values.firstWhere(
        (c) => c.value == value,
        orElse: () => ExpenseCategory.other,
      );
}
