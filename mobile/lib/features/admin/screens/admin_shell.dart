import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/screens/admin_courses_screen.dart';
import 'package:kickpro/features/admin/screens/admin_dashboard_screen.dart';
import 'package:kickpro/features/admin/screens/admin_drills_screen.dart';
import 'package:kickpro/features/admin/screens/admin_manage_screen.dart';
import 'package:kickpro/features/admin/screens/admin_venues_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _index = 0;

  static const _screens = [
    AdminDashboardScreen(),
    AdminVenuesScreen(),
    AdminDrillsScreen(),
    AdminCoursesScreen(),
    AdminManageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: ref.tr.adminHome),
          NavigationDestination(icon: const Icon(Icons.stadium_outlined), selectedIcon: const Icon(Icons.stadium), label: ref.tr.adminVenues),
          NavigationDestination(icon: const Icon(Icons.fitness_center_outlined), selectedIcon: const Icon(Icons.fitness_center), label: ref.tr.adminDrills),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: ref.tr.adminCourses),
          NavigationDestination(icon: const Icon(Icons.admin_panel_settings_outlined), selectedIcon: const Icon(Icons.admin_panel_settings), label: ref.tr.adminManage),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.small(
              onPressed: () => logout(ref),
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.logout, color: AppColors.textHint),
            )
          : null,
    );
  }
}
