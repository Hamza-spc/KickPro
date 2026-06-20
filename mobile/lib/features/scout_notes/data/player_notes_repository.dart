import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/features/scout_notes/models/player_note_models.dart';

final playerNotesRepositoryProvider = Provider<PlayerNotesRepository>((ref) {
  return PlayerNotesRepository(dio: ref.watch(apiClientProvider));
});

final myPlayerNotesProvider = FutureProvider.autoDispose<List<PlayerNote>>((ref) async {
  return ref.read(playerNotesRepositoryProvider).getMyNotes();
});

class PlayerNotesRepository {
  PlayerNotesRepository({required Dio dio}) : _dio = dio;
  final Dio _dio;

  Future<List<PlayerNote>> getMyNotes() async {
    final response = await _dio.get(ApiEndpoints.playerNotesMe);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => PlayerNote.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

