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

  static const drillProgression = '/api/v1/drills/progression';
  static String drillSubmit(int drillId) => '/api/v1/drills/$drillId/submit';
  static const drillBadgesMe = '/api/v1/drills/badges/me';

  static const stadiums = '/api/v1/stadiums';
  static String stadium(int id) => '/api/v1/stadiums/$id';

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
}
