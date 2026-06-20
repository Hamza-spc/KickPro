import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/features/leaderboard/models/leaderboard_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/api_response.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(dio: ref.watch(apiClientProvider));
});

class LeaderboardRepository {
  LeaderboardRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<LeaderboardEntry>> getLeaderboard(LeaderboardQuery query) async {
    final params = <String, String>{'type': query.type.apiValue};
    if (query.position != null) {
      params['position'] = query.position!.apiValue;
    }
    if (query.city != null && query.city!.isNotEmpty) {
      params['city'] = query.city!;
    }
    if (query.ageGroup != null) {
      params['ageGroup'] = query.ageGroup!.apiValue;
    }

    final response = await _dio.get(
      ApiEndpoints.leaderboard,
      queryParameters: params,
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final leaderboardProvider = FutureProvider.autoDispose
    .family<List<LeaderboardEntry>, LeaderboardQuery>((ref, query) {
  return ref.read(leaderboardRepositoryProvider).getLeaderboard(query);
});
