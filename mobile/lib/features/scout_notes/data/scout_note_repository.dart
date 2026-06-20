import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/features/scout_notes/models/scout_note_models.dart';
import 'package:kickpro/shared/models/api_response.dart';

final scoutNoteRepositoryProvider = Provider<ScoutNoteRepository>((ref) {
  return ScoutNoteRepository(dio: ref.watch(apiClientProvider));
});

class ScoutNoteRepository {
  ScoutNoteRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<ScoutNote?> getNote(int profileId) async {
    try {
      final response = await _dio.get(ApiEndpoints.scoutNote(profileId));
      final parsed = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => ScoutNote.fromJson(data as Map<String, dynamic>),
      );
      if (!parsed.success || parsed.data == null) {
        throw Exception(parsed.message);
      }
      return parsed.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<ScoutNote> saveNote({
    required int profileId,
    required int technicalAbility,
    required int potential,
    required String note,
    required bool exists,
  }) async {
    final data = {
      'technicalAbility': technicalAbility,
      'potential': potential,
      'note': note,
    };
    final response = exists
        ? await _dio.put(ApiEndpoints.scoutNote(profileId), data: data)
        : await _dio.post(ApiEndpoints.scoutNote(profileId), data: data);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ScoutNote.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<void> deleteNote(int profileId) async {
    await _dio.delete(ApiEndpoints.scoutNote(profileId));
  }
}

final scoutNoteProvider = FutureProvider.autoDispose.family<ScoutNote?, int>((ref, profileId) {
  return ref.read(scoutNoteRepositoryProvider).getNote(profileId);
});
