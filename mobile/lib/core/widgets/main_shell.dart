import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:checklist_management/core/theme/app_theme.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  // Index 2 is the center FAB placeholder — not a real tab
  static const _routes = [
    '/dashboard',
    '/templates',
    '', // placeholder for center FAB
    '/records',
    '/settings',
  ];

  void _handleTap(int index) {
    if (index == 2) return; // center FAB — handled separately
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;

    // Sync tab with current route
    final routeIndex = _routes.indexOf(location);
    if (routeIndex != -1 && routeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentIndex = routeIndex);
      });
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () => context.push('/records/form'),
          shape: const CircleBorder(),
          backgroundColor: AppColors.primary,
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          boxShadow: AppShadows.navShadow(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _handleTap,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.dashboard_rounded),
                activeIcon: _buildActiveIcon(Icons.dashboard_rounded),
                label: 'Tổng quan',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.description_rounded),
                activeIcon: _buildActiveIcon(Icons.description_rounded),
                label: 'Checklist',
              ),
              // Center placeholder for FAB
              const BottomNavigationBarItem(
                icon: SizedBox(height: 24),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.checklist_rounded),
                activeIcon: _buildActiveIcon(Icons.checklist_rounded),
                label: 'Lịch sử',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_rounded),
                activeIcon: _buildActiveIcon(Icons.settings_rounded),
                label: 'Cài đặt',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}
