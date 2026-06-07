import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../providers/settings_providers.dart';

/// Theme mode picker.
class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.darkMode,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
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
