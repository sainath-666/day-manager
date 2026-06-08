import 'package:flutter/cupertino.dart';
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

    // Select custom hand-crafted palette depending on selected seed color
    final Color primary;
    final Color secondary;
    final Color tertiary;
    final Color surface;
    final Color surfaceContainerLow;
    final Color surfaceContainer;
    final Color surfaceContainerHigh;
    final Color onSurface;
    final Color onSurfaceVariant;
    final Color outlineVariant;
    final Color outline;

    // Check seed color values
    final seedValue = seedColor.toARGB32();
    if (seedValue == 0xFF6366F1) {
      // Voyager Neon (Indigo)
      if (isDark) {
        primary = const Color(0xFF818CF8);
        secondary = const Color(0xFF2DD4BF);
        tertiary = const Color(0xFFA78BFA);
        surface = const Color(0xFF070A11);
        surfaceContainerLow = const Color(0xFF0F1524);
        surfaceContainer = const Color(0xFF161E33);
        surfaceContainerHigh = const Color(0xFF222E4D);
        onSurface = const Color(0xFFF4F4F5);
        onSurfaceVariant = const Color(0xFFA1A1AA);
        outlineVariant = const Color(0xFF1E293B);
        outline = const Color(0xFF475569);
      } else {
        primary = const Color(0xFF6366F1);
        secondary = const Color(0xFF14B8A6);
        tertiary = const Color(0xFF8B5CF6);
        surface = const Color(0xFFFAFAFA);
        surfaceContainerLow = const Color(0xFFFFFFFF);
        surfaceContainer = const Color(0xFFF4F4F5);
        surfaceContainerHigh = const Color(0xFFE4E4E7);
        onSurface = const Color(0xFF18181B);
        onSurfaceVariant = const Color(0xFF71717A);
        outlineVariant = const Color(0xFFE4E4E7);
        outline = const Color(0xFFA1A1AA);
      }
    } else if (seedValue == 0xFFE07A5F) {
      // Ethereal Rose (Rose Gold)
      if (isDark) {
        primary = const Color(0xFFF4A261);
        secondary = const Color(0xFFE76F51);
        tertiary = const Color(0xFF2A9D8F);
        surface = const Color(0xFF0F0D0E);
        surfaceContainerLow = const Color(0xFF1A1719);
        surfaceContainer = const Color(0xFF242022);
        surfaceContainerHigh = const Color(0xFF363033);
        onSurface = const Color(0xFFF4F1DE);
        onSurfaceVariant = const Color(0xFFB7B7A4);
        outlineVariant = const Color(0xFF2E292B);
        outline = const Color(0xFF5C5449);
      } else {
        primary = const Color(0xFFE07A5F);
        secondary = const Color(0xFF3D405B);
        tertiary = const Color(0xFF81B29A);
        surface = const Color(0xFFFAF9F6);
        surfaceContainerLow = const Color(0xFFFFFFFF);
        surfaceContainer = const Color(0xFFF4F1DE);
        surfaceContainerHigh = const Color(0xFFE3DFCE);
        onSurface = const Color(0xFF2B2D42);
        onSurfaceVariant = const Color(0xFF6C757D);
        outlineVariant = const Color(0xFFE3DFCE);
        outline = const Color(0xFFBDB2A6);
      }
    } else if (seedValue == 0xFF0D9488) {
      // Arctic Glacier (Teal)
      if (isDark) {
        primary = const Color(0xFF14B8A6);
        secondary = const Color(0xFF3B82F6);
        tertiary = const Color(0xFF38BDF8);
        surface = const Color(0xFF090F16);
        surfaceContainerLow = const Color(0xFF0F1824);
        surfaceContainer = const Color(0xFF162233);
        surfaceContainerHigh = const Color(0xFF24354F);
        onSurface = const Color(0xFFF8FAFC);
        onSurfaceVariant = const Color(0xFF94A3B8);
        outlineVariant = const Color(0xFF1E2D3E);
        outline = const Color(0xFF475569);
      } else {
        primary = const Color(0xFF0D9488);
        secondary = const Color(0xFF1D4ED8);
        tertiary = const Color(0xFF0EA5E9);
        surface = const Color(0xFFF3F7FA);
        surfaceContainerLow = const Color(0xFFFFFFFF);
        surfaceContainer = const Color(0xFFE0F2FE);
        surfaceContainerHigh = const Color(0xFFBAE6FD);
        onSurface = const Color(0xFF0F172A);
        onSurfaceVariant = const Color(0xFF475569);
        outlineVariant = const Color(0xFFE2E8F0);
        outline = const Color(0xFF94A3B8);
      }
    } else if (seedValue == 0xFF4E6E58) {
      // Eucalyptus Sage (Sage)
      if (isDark) {
        primary = const Color(0xFF7CA982);
        secondary = const Color(0xFFC5D3C1);
        tertiary = const Color(0xFFD4AF37);
        surface = const Color(0xFF0D110D);
        surfaceContainerLow = const Color(0xFF141A14);
        surfaceContainer = const Color(0xFF1A221A);
        surfaceContainerHigh = const Color(0xFF2A362A);
        onSurface = const Color(0xFFE8EBE8);
        onSurfaceVariant = const Color(0xFF8E9B91);
        outlineVariant = const Color(0xFF1D281D);
        outline = const Color(0xFF414E43);
      } else {
        primary = const Color(0xFF4E6E58);
        secondary = const Color(0xFF8A9A86);
        tertiary = const Color(0xFFB89C6F);
        surface = const Color(0xFFF4F6F4);
        surfaceContainerLow = const Color(0xFFFFFFFF);
        surfaceContainer = const Color(0xFFE8EBE8);
        surfaceContainerHigh = const Color(0xFFD6DDD6);
        onSurface = const Color(0xFF1C241E);
        onSurfaceVariant = const Color(0xFF5A665D);
        outlineVariant = const Color(0xFFD6DDD6);
        outline = const Color(0xFF8E9B91);
      }
    } else {
      // Default / Fallback
      if (isDark) {
        primary = seedColor;
        secondary = const Color(0xFF2DD4BF);
        tertiary = const Color(0xFFA78BFA);
        surface = const Color(0xFF090D16);
        surfaceContainerLow = const Color(0xFF111726);
        surfaceContainer = const Color(0xFF151D30);
        surfaceContainerHigh = const Color(0xFF1F2C47);
        onSurface = const Color(0xFFF8FAFC);
        onSurfaceVariant = const Color(0xFF94A3B8);
        outlineVariant = const Color(0xFF1F2C47);
        outline = const Color(0xFF334155);
      } else {
        primary = seedColor;
        secondary = const Color(0xFF14B8A6);
        tertiary = const Color(0xFF8B5CF6);
        surface = const Color(0xFFF8FAFC);
        surfaceContainerLow = const Color(0xFFFFFFFF);
        surfaceContainer = const Color(0xFFF1F5F9);
        surfaceContainerHigh = const Color(0xFFE2E8F0);
        onSurface = const Color(0xFF0F172A);
        onSurfaceVariant = const Color(0xFF475569);
        outlineVariant = const Color(0xFFE2E8F0);
        outline = const Color(0xFFCBD5E1);
      }
    }

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? Colors.black : Colors.white,
      primaryContainer: primary.withValues(alpha: 0.15),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: isDark ? Colors.black : Colors.white,
      secondaryContainer: secondary.withValues(alpha: 0.15),
      onSecondaryContainer: secondary,
      tertiary: tertiary,
      onTertiary: isDark ? Colors.black : Colors.white,
      tertiaryContainer: tertiary.withValues(alpha: 0.15),
      onTertiaryContainer: tertiary,
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      errorContainer: const Color(0xFFFEE2E2),
      onErrorContainer: const Color(0xFF991B1B),
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0),
        headlineMedium: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0),
        titleMedium: TextStyle(fontWeight: FontWeight.bold),
        titleSmall: TextStyle(fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 15, height: 1.45),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, height: 1.3),
        labelLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0),
        labelMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0),
        labelSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, letterSpacing: 0),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.55 : 0.75),
            width: 1.0,
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
          letterSpacing: 0,
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }
}
