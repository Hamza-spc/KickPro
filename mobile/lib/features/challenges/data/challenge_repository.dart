import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(dio: ref.watch(apiClientProvider));
});

final activeChallengeProvider = FutureProvider.autoDispose<WeeklyChallenge?>((ref) {
  return ref.read(challengeRepositoryProvider).getActiveChallenge();
});

final challengeSubmissionsProvider = FutureProvider.autoDispose<List<ChallengeSubmission>>((ref) {
  return ref.read(challengeRepositoryProvider).getSubmissions();
});

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.active,
  });

  final int id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;

  factory WeeklyChallenge.fromJson(Map<String, dynamic> json) {
    return WeeklyChallenge(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      active: json['active'] as bool? ?? true,
    );
  }
}

class ChallengeSubmission {
  const ChallengeSubmission({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.videoUrl,
    required this.votes,
    required this.submittedAt,
    required this.ownSubmission,
  });

  final int id;
  final int playerId;
  final String playerName;
  final String videoUrl;
  final int votes;
  final DateTime submittedAt;
  final bool ownSubmission;

  factory ChallengeSubmission.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmission(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String? ?? '',
      videoUrl: json['videoUrl'] as String,
      votes: (json['votes'] as num?)?.toInt() ?? 0,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      ownSubmission: json['ownSubmission'] as bool? ?? false,
    );
  }
}

class ChallengeRepository {
  ChallengeRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<WeeklyChallenge?> getActiveChallenge() async {
    try {
      final response = await _dio.get(ApiEndpoints.challengesActive);
      final parsed = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => WeeklyChallenge.fromJson(data as Map<String, dynamic>),
      );
      if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
      return parsed.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<ChallengeSubmission>> getSubmissions() async {
    final response = await _dio.get(ApiEndpoints.challengesSubmissions);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => ChallengeSubmission.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<ChallengeSubmission> submit(String videoUrl) async {
    final response = await _dio.post(
      ApiEndpoints.challengesSubmit,
      data: {'videoUrl': videoUrl},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ChallengeSubmission.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<ChallengeSubmission> vote(int submissionId) async {
    final response = await _dio.post(ApiEndpoints.challengeVote(submissionId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ChallengeSubmission.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }
}
