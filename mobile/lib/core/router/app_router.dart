import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/auth/auth_storage.dart';
import 'package:kickpro/features/auth/data/auth_repository.dart';
import 'package:kickpro/features/auth/screens/login_screen.dart';
import 'package:kickpro/features/auth/screens/register_screen.dart';
import 'package:kickpro/features/drills/screens/drill_submission_screen.dart';
import 'package:kickpro/features/home/screens/admin_home_screen.dart';
import 'package:kickpro/features/home/screens/player_home_screen.dart';
import 'package:kickpro/features/home/screens/scout_home_screen.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/screens/profile_setup_screen.dart';
import 'package:kickpro/features/profile/screens/skills_setup_screen.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/models/user_role.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.error?.toString() ?? 'Page not found',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: '/skills-setup', builder: (_, _) => const SkillsSetupScreen()),
      GoRoute(
        path: '/profile',
        redirect: (_, _) => '/home',
      ),
      GoRoute(path: '/home', builder: (_, _) => const PlayerHomeScreen()),
      GoRoute(path: '/scout-home', builder: (_, _) => const ScoutHomeScreen()),
      GoRoute(path: '/admin-home', builder: (_, _) => const AdminHomeScreen()),
      GoRoute(
        path: '/drills/:id/submit',
        builder: (context, state) {
          final drill = state.extra;
          if (drill is! DrillProgressionItem) {
            return const Scaffold(
              body: Center(child: Text('Drill not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return DrillSubmissionScreen(drill: drill);
        },
      ),
    ],
  );
});

Future<void> navigateAfterAuth(WidgetRef ref) async {
  final router = ref.read(routerProvider);
  final roleValue = await ref.read(authStorageProvider).getRole();
  final role = UserRole.fromApi(roleValue ?? UserRole.player.apiValue);

  if (role == UserRole.scout) {
    router.go('/scout-home');
    return;
  }
  if (role == UserRole.admin) {
    router.go('/admin-home');
    return;
  }

  final profileRepo = ref.read(profileRepositoryProvider);

  final hasProfile = await profileRepo.hasProfile();
  if (!hasProfile) {
    router.go('/profile-setup');
    return;
  }

  final hasSkills = await profileRepo.hasSkills();
  if (!hasSkills) {
    router.go('/skills-setup');
    return;
  }

  router.go('/home');
}

Future<void> logout(WidgetRef ref) async {
  await ref.read(authRepositoryProvider).logout();
  ref.read(routerProvider).go('/login');
}

final sessionBootstrapProvider = FutureProvider<bool>((ref) async {
  return ref.read(authStorageProvider).hasToken();
});
