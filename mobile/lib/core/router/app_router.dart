import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checklist_management/features/auth/presentation/login_screen.dart';
import 'package:checklist_management/features/auth/providers/auth_providers.dart';
import 'package:checklist_management/features/dashboard/presentation/dashboard_screen.dart';
import 'package:checklist_management/features/checklist/presentation/templates/template_list_screen.dart';
import 'package:checklist_management/features/checklist/presentation/records/record_list_screen.dart';
import 'package:checklist_management/features/checklist/presentation/records/record_form_screen.dart';
import 'package:checklist_management/features/settings/presentation/settings_screen.dart';
import 'package:checklist_management/core/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state for reactive redirect
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isOnLogin = state.uri.path == '/login';

      if (!isAuthenticated && !isOnLogin) {
        // Not logged in → force login
        return '/login';
      }
      if (isAuthenticated && isOnLogin) {
        // Already logged in → go to templates
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/templates',
            name: 'templates',
            builder: (context, state) => const TemplateListScreen(),
          ),
          GoRoute(
            path: '/records',
            name: 'records',
            builder: (context, state) {
              final templateId = state.uri.queryParameters['templateId'];
              return RecordListScreen(templateId: templateId);
            },
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/records/form',
        name: 'recordForm',
        builder: (context, state) {
          final templateId = state.uri.queryParameters['templateId'];
          final recordId = state.uri.queryParameters['recordId'];
          return RecordFormScreen(
            templateId: templateId,
            recordId: recordId,
          );
        },
      ),
      GoRoute(
        path: '/templates/:id/versions',
        name: 'templateVersions',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('Versions')));
        },
      ),
    ],
  );
});
