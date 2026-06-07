import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/theme/color_scheme.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.role,
    required this.email,
  });

  final String name;
  final String role;
  final String email;

  UserProfile copyWith({
    String? name,
    String? role,
    String? email,
  }) {
    return UserProfile(
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
    );
  }
}

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

class UserProfileNotifier extends Notifier<UserProfile> {
  Box get _box => Hive.box('settings');

  @override
  UserProfile build() {
    return UserProfile(
      name: (_box.get('profile_name', defaultValue: 'Rahul') as String).trim(),
      role: (_box.get('profile_role', defaultValue: 'Personal workspace') as String).trim(),
      email: (_box.get('profile_email', defaultValue: 'rahul@example.com') as String).trim(),
    );
  }

  void save(UserProfile profile) {
    final clean = UserProfile(
      name: profile.name.trim().isEmpty ? 'Rahul' : profile.name.trim(),
      role: profile.role.trim().isEmpty ? 'Personal workspace' : profile.role.trim(),
      email: profile.email.trim().isEmpty ? 'rahul@example.com' : profile.email.trim(),
    );
    state = clean;
    _box
      ..put('profile_name', clean.name)
      ..put('profile_role', clean.role)
      ..put('profile_email', clean.email);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);

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
