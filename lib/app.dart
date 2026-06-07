import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_providers.dart';
import 'shared/routing/app_router.dart';

/// Root application widget with theming and routing.
class DailyFlowApp extends ConsumerWidget {
  const DailyFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final seedColor = ref.watch(seedColorProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      theme: AppTheme.light(seedColor),
      darkTheme: AppTheme.dark(seedColor),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
