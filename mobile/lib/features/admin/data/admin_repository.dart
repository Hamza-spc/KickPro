import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/shared/models/api_response.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(dio: ref.watch(apiClientProvider));
});

class AdminRepository {
  AdminRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<AdminDashboardStats> getDashboard() async {
    final response = await _dio.get(ApiEndpoints.adminDashboard);
    return _parseData(response, AdminDashboardStats.fromJson);
  }

  Future<List<AdminStadium>> listStadiums() async {
    final response = await _dio.get(ApiEndpoints.adminStadiums);
    return _parseList(response, AdminStadium.fromJson);
  }

  Future<AdminStadium> createStadium(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.adminStadiums, data: body);
    return _parseData(response, AdminStadium.fromJson);
  }

  Future<AdminStadium> updateStadium(int id, Map<String, dynamic> body) async {
    final response = await _dio.put(ApiEndpoints.adminStadium(id), data: body);
    return _parseData(response, AdminStadium.fromJson);
  }

  Future<void> deleteStadium(int id) async {
    await _dio.delete(ApiEndpoints.adminStadium(id));
  }

  Future<AdminStadium> uploadStadiumPhotos(int id, List<String> filePaths) async {
    final formData = FormData.fromMap({
      'files': [
        for (final path in filePaths) await MultipartFile.fromFile(path),
      ],
    });
    final response = await _dio.post(
      ApiEndpoints.adminStadiumPhotos(id),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseData(response, AdminStadium.fromJson);
  }

  Future<List<AdminDrill>> listDrills() async {
    final response = await _dio.get(ApiEndpoints.adminDrills);
    return _parseList(response, AdminDrill.fromJson);
  }

  Future<AdminDrill> createDrill(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.adminDrills, data: body);
    return _parseData(response, AdminDrill.fromJson);
  }

  Future<AdminDrill> updateDrill(int id, Map<String, dynamic> body) async {
    final response = await _dio.put(ApiEndpoints.adminDrill(id), data: body);
    return _parseData(response, AdminDrill.fromJson);
  }

  Future<void> deleteDrill(int id) async {
    await _dio.delete(ApiEndpoints.adminDrill(id));
  }

  Future<List<AdminDrillSubmission>> pendingSubmissions() async {
    final response = await _dio.get(ApiEndpoints.adminPendingSubmissions);
    return _parseList(response, AdminDrillSubmission.fromJson);
  }

  Future<void> reviewSubmission(int id, {required String status, int? score}) async {
    await _dio.put(
      ApiEndpoints.adminReviewSubmission(id),
      data: {'status': status, if (score != null) 'score': score},
    );
  }

  Future<List<AdminCourseDetail>> listCourses() async {
    final response = await _dio.get(ApiEndpoints.adminCourses);
    return _parseList(response, AdminCourseDetail.fromJson);
  }

  Future<void> deleteCourse(int id) async {
    await _dio.delete(ApiEndpoints.adminCourse(id));
  }

  Future<void> uploadLessonMedia(int courseId, int lessonId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    await _dio.post(
      ApiEndpoints.adminLessonMedia(courseId, lessonId),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<List<AdminUser>> listUsers() async {
    final response = await _dio.get(ApiEndpoints.adminUsers);
    return _parseList(response, AdminUser.fromJson);
  }

  Future<void> banUser(int id) async {
    await _dio.put(ApiEndpoints.adminBanUser(id));
  }

  Future<void> unbanUser(int id) async {
    await _dio.put(ApiEndpoints.adminUnbanUser(id));
  }

  Future<void> verifyAgent(int id) async {
    await _dio.put(ApiEndpoints.adminVerifyAgent(id));
  }

  Future<List<AdminPost>> listPosts({bool flaggedOnly = false}) async {
    final response = await _dio.get(
      ApiEndpoints.adminPosts,
      queryParameters: {'flaggedOnly': flaggedOnly},
    );
    return _parseList(response, AdminPost.fromJson);
  }

  Future<void> flagPost(int id, {required bool flagged}) async {
    await _dio.put(ApiEndpoints.adminFlagPost(id), data: {'flagged': flagged});
  }

  Future<void> removePost(int id) async {
    await _dio.delete(ApiEndpoints.adminPost(id));
  }

  T _parseData<T>(Response<dynamic> response, T Function(Map<String, dynamic>) fromJson) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data as T;
  }

  List<T> _parseList<T>(Response<dynamic> response, T Function(Map<String, dynamic>) fromJson) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>).map((e) => fromJson(e as Map<String, dynamic>)).toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data as List<T>;
  }
}

final adminDashboardProvider = FutureProvider.autoDispose<AdminDashboardStats>((ref) {
  return ref.read(adminRepositoryProvider).getDashboard();
});

final adminStadiumsProvider = FutureProvider.autoDispose<List<AdminStadium>>((ref) {
  return ref.read(adminRepositoryProvider).listStadiums();
});

final adminDrillsProvider = FutureProvider.autoDispose<List<AdminDrill>>((ref) {
  return ref.read(adminRepositoryProvider).listDrills();
});

final adminPendingSubmissionsProvider = FutureProvider.autoDispose<List<AdminDrillSubmission>>((ref) {
  return ref.read(adminRepositoryProvider).pendingSubmissions();
});

final adminCoursesProvider = FutureProvider.autoDispose<List<AdminCourseDetail>>((ref) {
  return ref.read(adminRepositoryProvider).listCourses();
});

final adminUsersProvider = FutureProvider.autoDispose<List<AdminUser>>((ref) {
  return ref.read(adminRepositoryProvider).listUsers();
});

final adminPostsProvider = FutureProvider.autoDispose.family<List<AdminPost>, bool>((ref, flaggedOnly) {
  return ref.read(adminRepositoryProvider).listPosts(flaggedOnly: flaggedOnly);
});
