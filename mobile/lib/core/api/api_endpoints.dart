import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class ApiEndpoints {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return 'http://localhost:8080';
    // 10.0.2.2 is the Android emulator alias for the host machine only.
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    // Use 127.0.0.1 on Apple/desktop to avoid IPv6 localhost resolution issues.
    return 'http://127.0.0.1:8080';
  }

  static const register = '/api/v1/auth/register';
  static const login = '/api/v1/auth/login';
  static const playerProfile = '/api/v1/players/profile';
  static const playerProfileMe = '/api/v1/players/profile/me';
  static const playerProfilePhoto = '/api/v1/players/profile/photo';
  static const playerSkills = '/api/v1/players/skills';
  static const playerSkillsMe = '/api/v1/players/skills/me';

  static const videos = '/api/v1/videos';
  static const videoFeed = '/api/v1/videos/feed';
  static const videoMe = '/api/v1/videos/me';

  static const posts = '/api/v1/posts';
  static const postFeed = '/api/v1/posts/feed';
  static String post(int id) => '/api/v1/posts/$id';
  static String postComments(int id) => '/api/v1/posts/$id/comments';
  static String postReactions(int id) => '/api/v1/posts/$id/reactions';
  static String followPlayer(int profileId) => '/api/v1/players/$profileId/follow';

  static const drillProgression = '/api/v1/drills/progression';
  static String drillSubmit(int drillId) => '/api/v1/drills/$drillId/submit';
  static const drillBadgesMe = '/api/v1/drills/badges/me';

  static const leaderboard = '/api/v1/leaderboard';

  static const stadiums = '/api/v1/stadiums';
  static String stadium(int id) => '/api/v1/stadiums/$id';
  static String stadiumAvailability(int id) => '/api/v1/stadiums/$id/availability';

  static const matches = '/api/v1/matches';
  static const matchesOpen = '/api/v1/matches/open';
  static const matchesMine = '/api/v1/matches/mine';
  static String match(int id) => '/api/v1/matches/$id';
  static String matchJoin(int id) => '/api/v1/matches/$id/join';
  static String matchParticipantReview(int matchId, int participantId) =>
      '/api/v1/matches/$matchId/participants/$participantId/review';
  static String matchComplete(int id) => '/api/v1/matches/$id/complete';
  static String matchCancel(int id) => '/api/v1/matches/$id/cancel';
  static String matchRatings(int id) => '/api/v1/matches/$id/ratings';
  static String matchChatMessages(int id) => '/api/v1/matches/$id/chat/messages';

  static const courses = '/api/v1/courses';
  static String course(int id) => '/api/v1/courses/$id';
  static String lessonQuiz(int courseId, int lessonId) =>
      '/api/v1/courses/$courseId/lessons/$lessonId/quiz';
  static String submitQuiz(int courseId, int lessonId) =>
      '/api/v1/courses/$courseId/lessons/$lessonId/quiz/submit';
  static const myCertifications = '/api/v1/courses/certifications/me';
  static String playerCertifications(int profileId) =>
      '/api/v1/courses/certifications/player/$profileId';

  static const scoutPlayerSearch = '/api/v1/scouts/players/search';
  static const scoutPlayerCities = '/api/v1/scouts/players/cities';
  static String playerProfileById(int profileId) => '/api/v1/players/profile/$profileId';

  static const aiScoutAssist = '/api/v1/ai/scout-assist';
  static const aiExplainScore = '/api/v1/ai/explain-score';
  static const aiRecommendDrills = '/api/v1/ai/recommend-drills';
  static const aiMealPlan = '/api/v1/ai/meal-plan';
  static const aiRecoveryPlan = '/api/v1/ai/recovery-plan';
  static const aiGenerateCourse = '/api/v1/ai/generate-course';

  static const adminDashboard = '/api/v1/admin/dashboard';
  static const adminStadiums = '/api/v1/admin/stadiums';
  static String adminStadium(int id) => '/api/v1/admin/stadiums/$id';
  static String adminStadiumPhotos(int id) => '/api/v1/admin/stadiums/$id/photos';
  static const adminDrills = '/api/v1/admin/drills';
  static String adminDrill(int id) => '/api/v1/admin/drills/$id';
  static const adminPendingSubmissions = '/api/v1/admin/drills/submissions/pending';
  static String adminReviewSubmission(int id) => '/api/v1/admin/drills/submissions/$id/review';
  static const adminCourses = '/api/v1/admin/courses';
  static String adminCourse(int id) => '/api/v1/admin/courses/$id';
  static String adminLessonMedia(int courseId, int lessonId) =>
      '/api/v1/admin/courses/$courseId/lessons/$lessonId/media';
  static const adminUsers = '/api/v1/admin/users';
  static String adminBanUser(int id) => '/api/v1/admin/users/$id/ban';
  static String adminUnbanUser(int id) => '/api/v1/admin/users/$id/unban';
  static String adminVerifyAgent(int id) => '/api/v1/admin/users/$id/verify-agent';
  static const adminPosts = '/api/v1/admin/posts';
  static String adminPost(int id) => '/api/v1/admin/posts/$id';
  static String adminFlagPost(int id) => '/api/v1/admin/posts/$id/flag';
}
