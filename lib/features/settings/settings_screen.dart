import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'widgets/theme_picker.dart';

/// App settings screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ThemePicker(),
        ],
      ),
    );
  }
}
