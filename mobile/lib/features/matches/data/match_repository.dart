import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/match_models.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(dio: ref.watch(apiClientProvider));
});

class MatchRepository {
  MatchRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<Stadium>> getStadiums({String? city, String? name}) async {
    final params = <String, String>{};
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (name != null && name.isNotEmpty) params['name'] = name;
    final response = await _dio.get(
      ApiEndpoints.stadiums,
      queryParameters: params.isEmpty ? null : params,
    );
    return _parseList(response, Stadium.fromJson);
  }

  Future<StadiumAvailability> getStadiumAvailability({
    required int stadiumId,
    required DateTime date,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _dio.get(
      ApiEndpoints.stadiumAvailability(stadiumId),
      queryParameters: {'date': dateStr},
    );
    return _parseSingle(response, StadiumAvailability.fromJson);
  }

  Future<List<FootballMatch>> getOpenMatches({String? city}) async {
    final response = await _dio.get(
      ApiEndpoints.matches,
      queryParameters: city != null && city.isNotEmpty ? {'city': city} : null,
    );
    return _parseList(response, FootballMatch.fromJson);
  }

  Future<List<FootballMatch>> getMyMatches() async {
    final response = await _dio.get(ApiEndpoints.matchesMine);
    return _parseList(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> getMatch(int matchId) async {
    final response = await _dio.get(ApiEndpoints.match(matchId));
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> createMatch({
    required int stadiumId,
    required DateTime dateTime,
    required int maxPlayers,
    required int minAge,
    required int maxAge,
    required MatchGender gender,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.matches,
      data: {
        'stadiumId': stadiumId,
        'dateTime': formatMatchDateTime(dateTime),
        'maxPlayers': maxPlayers,
        'minAge': minAge,
        'maxAge': maxAge,
        'gender': gender.apiValue,
      },
    );
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> requestToJoin(int matchId) async {
    final response = await _dio.post(ApiEndpoints.matchJoin(matchId));
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> reviewParticipant({
    required int matchId,
    required int participantId,
    required ParticipantStatus status,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.matchParticipantReview(matchId, participantId),
      data: {'status': status.apiValue},
    );
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> completeMatch(int matchId) async {
    final response = await _dio.put(ApiEndpoints.matchComplete(matchId));
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<FootballMatch> cancelMatch(int matchId) async {
    final response = await _dio.put(ApiEndpoints.matchCancel(matchId));
    return _parseSingle(response, FootballMatch.fromJson);
  }

  Future<List<ChatMessage>> getChatMessages(int matchId) async {
    final response = await _dio.get(ApiEndpoints.matchChatMessages(matchId));
    return _parseList(response, ChatMessage.fromJson);
  }

  Future<ChatMessage> sendChatMessage({
    required int matchId,
    required String content,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.matchChatMessages(matchId),
      data: {'content': content},
    );
    return _parseSingle(response, ChatMessage.fromJson);
  }

  Future<PlayerMatchRating> submitRating({
    required int matchId,
    required int ratedPlayerId,
    required int performanceScore,
    required int punctualityScore,
    required int teamworkScore,
    required int behaviorScore,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.matchRatings(matchId),
      data: {
        'ratedPlayerId': ratedPlayerId,
        'performanceScore': performanceScore,
        'punctualityScore': punctualityScore,
        'teamworkScore': teamworkScore,
        'behaviorScore': behaviorScore,
      },
    );
    return _parseSingle(response, PlayerMatchRating.fromJson);
  }

  Future<List<PlayerMatchRating>> getMatchRatings(int matchId) async {
    final response = await _dio.get(ApiEndpoints.matchRatings(matchId));
    return _parseList(response, PlayerMatchRating.fromJson);
  }

  List<T> _parseList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }

  T _parseSingle<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }
}
