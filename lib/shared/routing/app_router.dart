import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/analytics_screen.dart';
import '../../features/appointments/appointment_detail_screen.dart';
import '../../features/bill_scanner/bill_scanner_screen.dart';
import '../../features/expenses/expense_detail_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/schedule/schedule_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/tasks/task_create_screen.dart';
import '../../features/tasks/task_detail_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../providers/settings_providers.dart';
import '../widgets/app_scaffold.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Application router configuration with onboarding redirect logic.
final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingCompleted = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: onboardingCompleted ? '/home' : '/onboarding',
    redirect: (context, state) {
      final path = state.uri.path;
      if (!onboardingCompleted && path != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingCompleted && path == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (ctx, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, __) => const TaskCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) => TaskDetailScreen(
                  taskId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/schedule',
            builder: (_, __) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/expenses',
            builder: (_, __) => const ExpensesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => ExpenseDetailScreen(
                  expenseId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const BillScannerScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/appointments/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => AppointmentDetailScreen(
          appointmentId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
