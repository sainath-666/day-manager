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
    final isDark = brightness == Brightness.dark;

    // Create base scheme from seed
    final baseScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    // Custom obsidian/slate layout colors to override muddy M3 defaults
    final colorScheme = baseScheme.copyWith(
      surface: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC), // Obsidian space-black vs Slate-50
      surfaceContainerLow: isDark ? const Color(0xFF111726) : const Color(0xFFFFFFFF), // Dark deep card vs Pure White
      surfaceContainer: isDark ? const Color(0xFF151D30) : const Color(0xFFF1F5F9), // Scaffold surfaces
      surfaceContainerHigh: isDark ? const Color(0xFF1F2C47) : const Color(0xFFE2E8F0),
      onSurface: isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A), // Pure white vs Charcoal
      onSurfaceVariant: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569), // Ice grey vs Slate-600
      outlineVariant: isDark ? const Color(0xFF1F2C47) : const Color(0xFFE2E8F0), // Borders
      outline: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.8),
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 14,
        ),
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
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
