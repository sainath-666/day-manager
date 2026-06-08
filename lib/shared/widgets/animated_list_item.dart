import 'package:flutter/material.dart';

import '../../core/utils/app_animations.dart';

/// Wraps a list child with staggered entrance animation.
class AnimatedListItem extends StatelessWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.stepMs = 45,
  });

  final int index;
  final Widget child;
  final int stepMs;

  @override
  Widget build(BuildContext context) {
    return child.staggerIn(index, stepMs: stepMs);
  }
}
