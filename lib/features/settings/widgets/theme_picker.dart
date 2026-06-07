import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/color_scheme.dart';
import '../../../providers/settings_providers.dart';

/// Accent color and theme mode picker.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedColor = ref.watch(seedColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.accentColor,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AppSeedColors.options.map((color) {
            final selected = color == seedColor;
            return GestureDetector(
              onTap: () =>
                  ref.read(seedColorProvider.notifier).setColor(color),
              child: CircleAvatar(
                radius: selected ? 20 : 16,
                backgroundColor: color,
                child: selected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.darkMode,
            style: Theme.of(context).textTheme.titleMedium),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text(AppStrings.systemTheme)),
            ButtonSegment(value: ThemeMode.light, label: Text(AppStrings.lightTheme)),
            ButtonSegment(value: ThemeMode.dark, label: Text(AppStrings.darkTheme)),
          ],
          selected: {themeMode},
          onSelectionChanged: (s) =>
              ref.read(themeModeProvider.notifier).setThemeMode(s.first),
        ),
      ],
    );
  }
}
