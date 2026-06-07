import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/theme/color_scheme.dart';

/// Persisted user-selected accent seed color.
class SeedColorNotifier extends Notifier<Color> {
  Box get _box => Hive.box('settings');

  @override
  Color build() {
    final colorVal = _box.get('seed_color');
    if (colorVal != null) {
      try {
        return Color(colorVal as int);
      } catch (_) {}
    }
    return AppSeedColors.options.first;
  }

  void setColor(Color color) {
    state = color;
    _box.put('seed_color', color.toARGB32());
  }
}

final seedColorProvider = NotifierProvider<SeedColorNotifier, Color>(SeedColorNotifier.new);

/// Persisted theme mode preference.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  Box get _box => Hive.box('settings');

  @override
  ThemeMode build() {
    final modeName = _box.get('theme_mode');
    if (modeName != null) {
      try {
        return ThemeMode.values.firstWhere((e) => e.name == modeName);
      } catch (_) {}
    }
    return ThemeMode.system;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _box.put('theme_mode', mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Persisted onboarding completion status.
class OnboardingNotifier extends Notifier<bool> {
  Box get _box => Hive.box('settings');

  @override
  bool build() {
    return _box.get('onboarding_completed', defaultValue: false) as bool;
  }

  void completeOnboarding() {
    state = true;
    _box.put('onboarding_completed', true);
  }
}

final onboardingCompletedProvider = NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);
