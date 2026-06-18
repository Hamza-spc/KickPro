import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/auth/auth_storage.dart';
import 'package:kickpro/features/auth/data/auth_repository.dart';
import 'package:kickpro/features/auth/screens/login_screen.dart';
import 'package:kickpro/features/auth/screens/register_screen.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/features/profile/screens/profile_setup_screen.dart';
import 'package:kickpro/features/profile/screens/skills_setup_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: '/skills-setup', builder: (_, _) => const SkillsSetupScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const PlayerProfileScreen()),
    ],
  );
});

Future<void> navigateAfterAuth(WidgetRef ref) async {
  final router = ref.read(routerProvider);
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

  router.go('/profile');
}

Future<void> logout(WidgetRef ref) async {
  await ref.read(authRepositoryProvider).logout();
  ref.read(routerProvider).go('/login');
}

final sessionBootstrapProvider = FutureProvider<bool>((ref) async {
  return ref.read(authStorageProvider).hasToken();
});
