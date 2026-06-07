import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Task priority levels.
enum Priority {
  low(0, 'Low', AppColors.priorityLow),
  medium(1, 'Medium', AppColors.priorityMedium),
  high(2, 'High', AppColors.priorityHigh);

  const Priority(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  static Priority fromInt(int value) =>
      Priority.values.firstWhere((p) => p.value == value, orElse: () => Priority.low);
}
