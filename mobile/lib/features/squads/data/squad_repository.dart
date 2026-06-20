import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/squad_models.dart';

final squadRepositoryProvider = Provider<SquadRepository>((ref) {
  return SquadRepository(dio: ref.watch(apiClientProvider));
});

final mySquadsProvider = FutureProvider.autoDispose<List<SquadSummary>>((ref) {
  return ref.read(squadRepositoryProvider).getMySquads();
});

final discoverSquadsProvider = FutureProvider.autoDispose
    .family<List<SquadDiscoverItem>, String>((ref, city) {
  return ref.read(squadRepositoryProvider).discoverSquads(city: city);
});

final incomingJoinRequestsProvider = FutureProvider.autoDispose<List<SquadJoinRequestItem>>((ref) {
  return ref.read(squadRepositoryProvider).getIncomingJoinRequests();
});

class SquadRepository {
  SquadRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<SquadSummary>> getMySquads() async {
    final response = await _dio.get(ApiEndpoints.squadsMine);
    return _parseList(response, SquadSummary.fromJson);
  }

  Future<List<SquadDiscoverItem>> discoverSquads({required String city}) async {
    final response = await _dio.get(
      ApiEndpoints.squadsDiscover,
      queryParameters: {'city': city},
    );
    return _parseList(response, SquadDiscoverItem.fromJson);
  }

  Future<List<SquadJoinRequestItem>> getIncomingJoinRequests() async {
    final response = await _dio.get(ApiEndpoints.squadsJoinRequestsIncoming);
    return _parseList(response, SquadJoinRequestItem.fromJson);
  }

  Future<SquadSummary> getSquad(int id) async {
    final response = await _dio.get(ApiEndpoints.squad(id));
    return _parseSingle(response, SquadSummary.fromJson);
  }

  Future<SquadSummary> createSquad({
    required String name,
    required String city,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.squads,
      data: {'name': name, 'city': city},
    );
    return _parseSingle(response, SquadSummary.fromJson);
  }

  Future<SquadJoinRequestItem> requestJoin(int squadId) async {
    final response = await _dio.post(ApiEndpoints.squadJoinRequest(squadId));
    return _parseSingle(response, SquadJoinRequestItem.fromJson);
  }

  Future<SquadJoinRequestItem> approveJoinRequest(int requestId) async {
    final response = await _dio.post(ApiEndpoints.squadJoinRequestApprove(requestId));
    return _parseSingle(response, SquadJoinRequestItem.fromJson);
  }

  Future<SquadJoinRequestItem> rejectJoinRequest(int requestId) async {
    final response = await _dio.post(ApiEndpoints.squadJoinRequestReject(requestId));
    return _parseSingle(response, SquadJoinRequestItem.fromJson);
  }

  Future<SquadSummary> invitePlayer({
    required int squadId,
    required int profileId,
  }) async {
    final response = await _dio.post(ApiEndpoints.squadInvite(squadId, profileId));
    return _parseSingle(response, SquadSummary.fromJson);
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
