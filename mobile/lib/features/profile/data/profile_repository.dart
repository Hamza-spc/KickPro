import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/skills_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(dio: ref.watch(apiClientProvider));
});

class ProfileRepository {
  ProfileRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<PlayerProfile> saveProfile(PlayerProfile profile) async {
    final response = await _dio.put(
      ApiEndpoints.playerProfile,
      data: profile.toJson(),
    );
    return _parseProfile(response);
  }

  Future<PlayerProfile> getMyProfile() async {
    final response = await _dio.get(ApiEndpoints.playerProfileMe);
    return _parseProfile(response);
  }

  Future<PlayerProfile> uploadPhoto(String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      ApiEndpoints.playerProfilePhoto,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parseProfile(response);
  }

  Future<PlayerProfile> deletePhoto() async {
    final response = await _dio.delete(ApiEndpoints.playerProfilePhoto);
    return _parseProfile(response);
  }

  Future<PlayerProfile> updateInjury({
    required bool injured,
    String? injuryType,
    String? injuryBodyPart,
    String? injurySeverity,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.playerProfileInjury,
      data: {
        'injured': injured,
        'injuryType': injuryType,
        'injuryBodyPart': injuryBodyPart,
        'injurySeverity': injurySeverity,
      },
    );
    return _parseProfile(response);
  }

  Future<PlayerSkills> saveSkills(PlayerSkills skills) async {
    final response = await _dio.put(
      ApiEndpoints.playerSkills,
      data: skills.toJson(),
    );
    return _parseSkills(response);
  }

  Future<PlayerSkills> getMySkills() async {
    final response = await _dio.get(ApiEndpoints.playerSkillsMe);
    return _parseSkills(response);
  }

  Future<bool> hasProfile() async {
    try {
      await getMyProfile();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  Future<bool> hasSkills() async {
    try {
      await getMySkills();
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      rethrow;
    }
  }

  PlayerProfile _parseProfile(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PlayerProfile.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  PlayerSkills _parseSkills(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PlayerSkills.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }
}
