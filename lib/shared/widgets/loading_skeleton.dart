import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_sizes.dart';

/// Shimmer-style loading placeholder.
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.height = 72,
    this.width,
    this.borderRadius = AppSizes.radiusMd,
    this.index = 0,
  });

  final double height;
  final double? width;
  final double borderRadius;
  final int index;

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
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1400.ms,
          delay: (index * 80).ms,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        )
        .fadeIn(duration: 300.ms, delay: (index * 60).ms);
  }
}
