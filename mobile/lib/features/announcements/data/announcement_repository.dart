import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/announcement_models.dart';
import 'package:kickpro/shared/models/api_response.dart';

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepository(dio: ref.watch(apiClientProvider));
});

final announcementsProvider = FutureProvider.autoDispose
    .family<List<Announcement>, String?>((ref, city) {
  return ref.read(announcementRepositoryProvider).getAnnouncements(city: city);
});

class AnnouncementRepository {
  AnnouncementRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<Announcement>> getAnnouncements({String? city}) async {
    final response = await _dio.get(
      ApiEndpoints.announcements,
      queryParameters: city != null && city.isNotEmpty ? {'city': city} : null,
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => Announcement.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<Announcement> create(CreateAnnouncementRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.announcements,
      data: request.toJson(),
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => Announcement.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<Announcement> uploadImage({required int id, required String filePath}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
    });
    final response = await _dio.post(ApiEndpoints.announcementImage(id), data: form);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => Announcement.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<void> delete(int id) async {
    await _dio.delete(ApiEndpoints.announcement(id));
  }
}
