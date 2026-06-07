import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/color_scheme.dart';

/// User-selected accent seed color.
final seedColorProvider =
    StateProvider<Color>((ref) => AppSeedColors.options.first);

/// Theme mode preference.
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.system);
