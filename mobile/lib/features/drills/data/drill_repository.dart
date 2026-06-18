import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/drill_models.dart';

final drillRepositoryProvider = Provider<DrillRepository>((ref) {
  return DrillRepository(dio: ref.watch(apiClientProvider));
});

class DrillRepository {
  DrillRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<DrillProgressionItem>> getProgression(DrillLevel level) async {
    final response = await _dio.get(
      ApiEndpoints.drillProgression,
      queryParameters: {'level': level.apiValue},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => DrillProgressionItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> submitDrill({required int drillId, required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      ApiEndpoints.drillSubmit(drillId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data,
    );
    if (!parsed.success) {
      throw Exception(parsed.message);
    }
  }

  Future<List<PlayerBadge>> getMyBadges() async {
    final response = await _dio.get(ApiEndpoints.drillBadgesMe);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => PlayerBadge.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
