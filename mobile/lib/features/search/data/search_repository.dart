import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/search_models.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(dio: ref.watch(apiClientProvider));
});

class SearchRepository {
  SearchRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PagedPlayers> searchPlayers({
    required PlayerSearchFilters filters,
    required int page,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.scoutPlayerSearch,
      queryParameters: filters.toQueryParameters(page: page, size: size),
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PagedPlayers.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<PlayerProfile> getPlayerProfile(int profileId) async {
    final response = await _dio.get(ApiEndpoints.playerProfileById(profileId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PlayerProfile.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<List<String>> getCities() async {
    final response = await _dio.get(ApiEndpoints.scoutPlayerCities);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!.cast<String>();
  }
}
