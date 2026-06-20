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
import 'package:kickpro/features/admin/screens/admin_create_course_screen.dart';
import 'package:kickpro/features/admin/screens/admin_shell.dart';
import 'package:kickpro/features/leaderboard/screens/leaderboard_screen.dart';
import 'package:kickpro/features/home/screens/agent_home_screen.dart';
import 'package:kickpro/features/home/screens/player_home_screen.dart';
import 'package:kickpro/features/home/screens/scout_home_screen.dart';
import 'package:kickpro/features/courses/screens/lesson_detail_screen.dart';
import 'package:kickpro/features/courses/models/lesson_view_args.dart';
import 'package:kickpro/features/courses/screens/course_detail_screen.dart';
import 'package:kickpro/features/courses/screens/course_quiz_screen.dart';
import 'package:kickpro/features/courses/screens/courses_list_screen.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/screens/edit_profile_screen.dart';
import 'package:kickpro/features/profile/screens/profile_setup_screen.dart';
import 'package:kickpro/features/profile/screens/skills_setup_screen.dart';
import 'package:kickpro/features/profile/screens/user_profile_screen.dart';
import 'package:kickpro/features/ai/screens/admin_generate_course_screen.dart';
import 'package:kickpro/features/ai/screens/ai_coach_screen.dart';
import 'package:kickpro/features/ai/screens/ai_text_result_screen.dart';
import 'package:kickpro/features/ai/screens/drill_recommendations_screen.dart';
import 'package:kickpro/features/ai/screens/recovery_plan_screen.dart';
import 'package:kickpro/features/announcements/screens/announcements_screen.dart';
import 'package:kickpro/features/messages/screens/messages_tab.dart';
import 'package:kickpro/features/notifications/screens/notifications_screen.dart';
import 'package:kickpro/features/challenges/screens/challenges_screen.dart';
import 'package:kickpro/features/search/screens/compare_players_screen.dart';
import 'package:kickpro/features/search/screens/bookmarks_split_compare_screen.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/features/scout_notes/screens/player_notes_screen.dart';
import 'package:kickpro/features/clubs/screens/club_detail_screen.dart';
import 'package:kickpro/features/clubs/screens/clubs_list_screen.dart';
import 'package:kickpro/features/squads/screens/join_squads_screen.dart';
import 'package:kickpro/features/squads/screens/squads_screen.dart';
import 'package:kickpro/shared/models/ai_models.dart';
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
      GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/skills-setup', builder: (_, _) => const SkillsSetupScreen()),
      GoRoute(
        path: '/profile',
        redirect: (_, _) => '/home',
      ),
      GoRoute(
        path: '/players/:profileId',
        builder: (context, state) {
          final profileId = int.tryParse(state.pathParameters['profileId'] ?? '');
          if (profileId == null) {
            return const Scaffold(
              body: Center(child: Text('Profile not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return UserProfileScreen(profileId: profileId);
        },
      ),
      GoRoute(path: '/leaderboard', builder: (_, _) => const LeaderboardScreen()),
      GoRoute(path: '/announcements', builder: (_, _) => const AnnouncementsScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(
        path: '/messages/chat/:userId',
        builder: (context, state) {
          final userId = int.tryParse(state.pathParameters['userId'] ?? '');
          if (userId == null) {
            return const Scaffold(
              body: Center(child: Text('Conversation not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return MessagesChatScreen(
            otherUserId: userId,
            otherUserLabel: state.uri.queryParameters['label'],
          );
        },
      ),
      GoRoute(path: '/challenges', builder: (_, _) => const ChallengesScreen()),
      GoRoute(path: '/notes', builder: (_, _) => const PlayerNotesScreen()),
      GoRoute(
        path: '/compare',
        builder: (context, state) {
          final a = int.tryParse(state.uri.queryParameters['a'] ?? '');
          final b = int.tryParse(state.uri.queryParameters['b'] ?? '');
          return ComparePlayersScreen(initialProfileA: a, initialProfileB: b);
        },
      ),
      GoRoute(
        path: '/bookmarks/compare',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! List || extra.length != 2) {
            return const Scaffold(
              body: Center(child: Text('Compare not available', style: TextStyle(color: Colors.white70))),
            );
          }
          final left = extra[0];
          final right = extra[1];
          if (left is! PlayerSearchResult || right is! PlayerSearchResult) {
            return const Scaffold(
              body: Center(child: Text('Compare not available', style: TextStyle(color: Colors.white70))),
            );
          }
          return BookmarksSplitCompareScreen(left: left, right: right);
        },
      ),
      GoRoute(path: '/agent-home', builder: (_, _) => const AgentHomeScreen()),
      GoRoute(path: '/squads', builder: (_, _) => const SquadsScreen()),
      GoRoute(path: '/squads/join', builder: (_, _) => const JoinSquadsScreen()),
      GoRoute(path: '/clubs', builder: (_, _) => const ClubsListScreen()),
      GoRoute(
        path: '/clubs/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const Scaffold(
              body: Center(child: Text('Club not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return ClubDetailScreen(clubId: id);
        },
      ),
      GoRoute(path: '/home', builder: (_, _) => const PlayerHomeScreen()),
      GoRoute(path: '/scout-home', builder: (_, _) => const ScoutHomeScreen()),
      GoRoute(path: '/admin-home', builder: (_, _) => const AdminShell()),
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
      GoRoute(path: '/ai/coach', builder: (_, _) => const AiCoachScreen()),
      GoRoute(
        path: '/ai/drill-recommendations',
        builder: (_, _) => const DrillRecommendationsScreen(),
      ),
      GoRoute(path: '/ai/recovery-plan', builder: (_, _) => const RecoveryPlanScreen()),
      GoRoute(
        path: '/ai/text/:action',
        builder: (context, state) {
          final action = switch (state.pathParameters['action']) {
            'meal-plan' => AiTextAction.mealPlan,
            'explain-score' => AiTextAction.explainScore,
            'video-feedback' => AiTextAction.videoFeedback,
            _ => null,
          };
          if (action == null) {
            return const Scaffold(
              body: Center(child: Text('AI action not found', style: TextStyle(color: Colors.white70))),
            );
          }
          return AiTextResultScreen(
            action: action,
            videoUrl: state.uri.queryParameters['videoUrl'],
            skillTag: state.uri.queryParameters['skillTag'],
          );
        },
      ),
      GoRoute(
        path: '/admin/generate-course',
        builder: (_, _) => const AdminGenerateCourseScreen(),
      ),
      GoRoute(
        path: '/admin/create-course',
        builder: (_, _) => const AdminCreateCourseScreen(),
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
  if (role == UserRole.agent) {
    router.go('/agent-home');
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
