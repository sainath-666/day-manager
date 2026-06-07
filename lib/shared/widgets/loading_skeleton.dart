import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';

/// Shimmer-style loading placeholder.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.height = 72,
    this.width,
    this.borderRadius = AppSizes.radiusMd,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
