import 'package:flutter/material.dart';

import '../constants/app_sizes.dart';

/// Material 3 light and dark themes.
abstract final class AppTheme {
  static ThemeData light(Color seedColor) => _theme(
        seedColor: seedColor,
        brightness: Brightness.light,
      );

  static ThemeData dark(Color seedColor) => _theme(
        seedColor: seedColor,
        brightness: Brightness.dark,
      );

  static ThemeData _theme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: colorScheme.surface,
        cardTheme: CardThemeData(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: colorScheme.surfaceContainer,
          indicatorColor: colorScheme.primaryContainer,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
      );
  }
}
