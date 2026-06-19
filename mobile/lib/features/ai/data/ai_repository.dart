import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/models/api_response.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepository(dio: ref.watch(apiClientProvider));
});

class AiRepository {
  AiRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  static const _aiTimeout = Duration(seconds: 90);

  Future<ScoutAssistResponse> scoutAssist(String query) async {
    final response = await _dio.post(
      ApiEndpoints.aiScoutAssist,
      data: {'query': query},
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, ScoutAssistResponse.fromJson);
  }

  Future<AiTextResponse> explainScore() async {
    final response = await _dio.post(
      ApiEndpoints.aiExplainScore,
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, AiTextResponse.fromJson);
  }

  Future<DrillRecommendationResponse> recommendDrills() async {
    final response = await _dio.post(
      ApiEndpoints.aiRecommendDrills,
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, DrillRecommendationResponse.fromJson);
  }

  Future<AiTextResponse> mealPlan() async {
    final response = await _dio.post(
      ApiEndpoints.aiMealPlan,
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, AiTextResponse.fromJson);
  }

  Future<AiTextResponse> recoveryPlan(RecoveryPlanRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.aiRecoveryPlan,
      data: request.toJson(),
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, AiTextResponse.fromJson);
  }

  Future<GeneratedCourseResponse> generateCourse({
    required String title,
    required String description,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.aiGenerateCourse,
      data: {'title': title, 'description': description},
      options: Options(receiveTimeout: _aiTimeout, sendTimeout: _aiTimeout),
    );
    return _parse(response, GeneratedCourseResponse.fromJson);
  }

  T _parse<T>(
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
    return parsed.data as T;
  }
}
