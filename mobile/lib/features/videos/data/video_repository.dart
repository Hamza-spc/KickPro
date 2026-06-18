import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/video_models.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(dio: ref.watch(apiClientProvider));
});

class VideoRepository {
  VideoRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<PerformanceVideo>> getFeed({int page = 0, int size = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.videoFeed,
      queryParameters: {'page': page, 'size': size},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as Map<String, dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    final content = parsed.data!['content'] as List<dynamic>;
    return content
        .map((item) => PerformanceVideo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PerformanceVideo>> getMyVideos() async {
    final response = await _dio.get(ApiEndpoints.videoMe);
    return _parseVideoList(response);
  }

  Future<PerformanceVideo> uploadVideo({
    required String title,
    required TargetSkill skillTag,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'skillTag': skillTag.apiValue,
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      ApiEndpoints.videos,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseVideo(response);
  }

  List<PerformanceVideo> _parseVideoList(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => PerformanceVideo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  PerformanceVideo _parseVideo(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PerformanceVideo.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }
}
