import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Shared animation durations, curves, and helpers.
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 450);

  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve bounceCurve = Curves.easeOutBack;

  static int staggerDelay(int index, {int stepMs = 45, int maxMs = 360}) =>
      (index * stepMs).clamp(0, maxMs);

  /// Smooth modal bottom sheet with slide-up content.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: child
              .animate()
              .fadeIn(duration: 280.ms, curve: enterCurve)
              .slideY(begin: 0.06, end: 0, duration: 320.ms, curve: enterCurve),
        );
      },
    );
  }

  /// Fade + subtle slide page transition for pushed routes.
  static Widget fadeSlideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: enterCurve);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.025),
      end: Offset.zero,
    ).animate(curved);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// Staggered list entrance animation.
extension StaggeredEntrance on Widget {
  Widget staggerIn(
    int index, {
    int stepMs = 45,
    double slideY = 0.08,
    double slideX = 0,
  }) {
    final delay = AppAnimations.staggerDelay(index, stepMs: stepMs);
    return animate()
        .fadeIn(
          duration: AppAnimations.normal,
          delay: delay.ms,
          curve: AppAnimations.enterCurve,
        )
        .slideY(
          begin: slideY,
          end: 0,
          duration: AppAnimations.slow,
          delay: delay.ms,
          curve: AppAnimations.enterCurve,
        )
        .slideX(
          begin: slideX,
          end: 0,
          duration: AppAnimations.slow,
          delay: delay.ms,
          curve: AppAnimations.enterCurve,
        );
  }
}

/// iOS-style bounce scrolling on all platforms.
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}
