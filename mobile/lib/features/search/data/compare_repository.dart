import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/search_models.dart';

final compareRepositoryProvider = Provider<CompareRepository>((ref) {
  return CompareRepository(dio: ref.watch(apiClientProvider));
});

final playerComparisonProvider = FutureProvider.autoDispose
    .family<PlayerComparison, ({int profileA, int profileB})>((ref, ids) {
  return ref.read(compareRepositoryProvider).comparePlayers(ids.profileA, ids.profileB);
});

class PlayerComparison {
  const PlayerComparison({required this.profileA, required this.profileB});

  final PlayerSearchResult profileA;
  final PlayerSearchResult profileB;

  factory PlayerComparison.fromJson(Map<String, dynamic> json) {
    return PlayerComparison(
      profileA: PlayerSearchResult.fromJson(json['profileA'] as Map<String, dynamic>),
      profileB: PlayerSearchResult.fromJson(json['profileB'] as Map<String, dynamic>),
    );
  }
}

class CompareRepository {
  CompareRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PlayerComparison> comparePlayers(int profileA, int profileB) async {
    final response = await _dio.get(ApiEndpoints.scoutComparePlayers(profileA, profileB));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PlayerComparison.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }
}
