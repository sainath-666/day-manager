import 'package:flutter/material.dart';

import '../../core/utils/app_animations.dart';

/// Tappable widget with subtle press-scale feedback.
class ScaleTap extends StatefulWidget {
  const ScaleTap({
    super.key,
    required this.child,
    required this.onTap,
    this.scale = 0.96,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: AppAnimations.fast,
        curve: AppAnimations.bounceCurve,
        child: widget.child,
      ),
    );
  }
}
