import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/auth/auth_storage.dart';
import 'package:kickpro/features/auth/data/auth_repository.dart';
import 'package:kickpro/features/auth/screens/login_screen.dart';
import 'package:kickpro/features/auth/screens/register_screen.dart';
import 'package:kickpro/features/drills/screens/drill_submission_screen.dart';
import 'package:kickpro/features/matches/screens/match_chat_screen.dart';
import 'package:kickpro/features/matches/screens/match_detail_screen.dart';
import 'package:kickpro/features/matches/screens/match_rating_screen.dart';
import 'package:kickpro/features/home/screens/admin_home_screen.dart';
import 'package:kickpro/features/home/screens/player_home_screen.dart';
import 'package:kickpro/features/home/screens/scout_home_screen.dart';
import 'package:kickpro/features/courses/screens/lesson_detail_screen.dart';
import 'package:kickpro/features/courses/models/lesson_view_args.dart';
import 'package:kickpro/features/courses/screens/course_detail_screen.dart';
import 'package:kickpro/features/courses/screens/course_quiz_screen.dart';
import 'package:kickpro/features/courses/screens/courses_list_screen.dart';
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
      GoRoute(
        path: '/matches/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Match not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return MatchDetailScreen(matchId: id);
        },
      ),
      GoRoute(
        path: '/matches/:id/chat',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Match not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return MatchChatScreen(matchId: id);
        },
      ),
      GoRoute(
        path: '/matches/:id/rate',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Match not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return MatchRatingScreen(matchId: id);
        },
      ),
      GoRoute(path: '/courses', builder: (_, _) => const CoursesListScreen()),
      GoRoute(
        path: '/courses/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Course not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return CourseDetailScreen(courseId: id);
        },
      ),
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId/quiz',
        builder: (context, state) {
          final courseId = int.tryParse(state.pathParameters['courseId'] ?? '');
          final lessonId = int.tryParse(state.pathParameters['lessonId'] ?? '');
          if (courseId == null || lessonId == null) {
            return const Scaffold(
              body: Center(child: Text('Quiz not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return CourseQuizScreen(courseId: courseId, lessonId: lessonId);
        },
      ),
      GoRoute(
        path: '/courses/:courseId/lessons/:lessonId',
        builder: (context, state) {
          final args = state.extra;
          if (args is! LessonViewArgs) {
            return const Scaffold(
              body: Center(child: Text('Lesson not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return LessonDetailScreen(args: args);
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
