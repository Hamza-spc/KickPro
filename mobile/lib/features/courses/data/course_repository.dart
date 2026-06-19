import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/models/drill_models.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(dio: ref.watch(apiClientProvider));
});

final coursesListProvider = FutureProvider.autoDispose<List<CourseSummary>>((ref) {
  return ref.read(courseRepositoryProvider).listCourses();
});

final courseDetailProvider = FutureProvider.autoDispose.family<CourseDetail, int>((ref, courseId) {
  return ref.read(courseRepositoryProvider).getCourse(courseId);
});

final myCertificationsProvider = FutureProvider.autoDispose<List<Certification>>((ref) {
  return ref.read(courseRepositoryProvider).getMyCertifications();
});

final courseQuizProvider = FutureProvider.autoDispose
    .family<CourseQuiz, ({int courseId, int lessonId})>((ref, params) {
  return ref.read(courseRepositoryProvider).getQuiz(
        courseId: params.courseId,
        lessonId: params.lessonId,
      );
});

class CourseRepository {
  CourseRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<CourseSummary>> listCourses({DrillLevel? level}) async {
    final response = await _dio.get(
      ApiEndpoints.courses,
      queryParameters: level == null ? null : {'level': level.apiValue},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => CourseSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CourseDetail> getCourse(int courseId) async {
    final response = await _dio.get(ApiEndpoints.course(courseId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => CourseDetail.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<CourseQuiz> getQuiz({required int courseId, required int lessonId}) async {
    final response = await _dio.get(ApiEndpoints.lessonQuiz(courseId, lessonId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => CourseQuiz.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<QuizResult> submitQuiz({
    required int courseId,
    required int lessonId,
    required Map<int, int> answersByQuestionId,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.submitQuiz(courseId, lessonId),
      data: {
        'answers': answersByQuestionId.entries
            .map((entry) => {
                  'questionId': entry.key,
                  'selectedOptionIndex': entry.value,
                })
            .toList(),
      },
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => QuizResult.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<List<Certification>> getMyCertifications() async {
    final response = await _dio.get(ApiEndpoints.myCertifications);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => Certification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Certification>> getPlayerCertifications(int profileId) async {
    final response = await _dio.get(ApiEndpoints.playerCertifications(profileId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => Certification.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
