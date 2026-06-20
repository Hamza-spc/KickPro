import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/club_models.dart';

final clubRepositoryProvider = Provider<ClubRepository>((ref) {
  return ClubRepository(dio: ref.watch(apiClientProvider));
});

final clubsListProvider = FutureProvider.autoDispose<List<ClubSummary>>((ref) {
  return ref.read(clubRepositoryProvider).getClubs();
});

final clubDetailProvider = FutureProvider.autoDispose.family<ClubSummary, int>((ref, id) {
  return ref.read(clubRepositoryProvider).getClub(id);
});

class ClubRepository {
  ClubRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<ClubSummary>> getClubs({String? city}) async {
    final response = await _dio.get(
      ApiEndpoints.clubs,
      queryParameters: city != null && city.isNotEmpty ? {'city': city} : null,
    );
    return _parseList(response, ClubSummary.fromJson);
  }

  Future<ClubSummary> getClub(int id) async {
    final response = await _dio.get(ApiEndpoints.club(id));
    return _parseSingle(response, ClubSummary.fromJson);
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
