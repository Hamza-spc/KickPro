import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/core/auth/auth_storage.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/auth_models.dart';
import 'package:kickpro/shared/models/user_role.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(apiClientProvider),
    storage: ref.watch(authStorageProvider),
  );
});

class AuthRepository {
  AuthRepository({required Dio dio, required AuthStorage storage})
      : _dio = dio,
        _storage = storage;

  final Dio _dio;
  final AuthStorage _storage;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: {
        'email': email.trim(),
        'password': password,
        'role': role.apiValue,
      },
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    await _persistSession(parsed.data!);
    return parsed.data!;
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email.trim(), 'password': password},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    await _persistSession(parsed.data!);
    return parsed.data!;
  }

  Future<void> logout() => _storage.clear();

  Future<bool> isLoggedIn() => _storage.hasToken();

  Future<void> _persistSession(AuthResponse auth) async {
    await _storage.saveSession(
      token: auth.token,
      role: auth.role.apiValue,
      userId: auth.userId,
    );
  }
}

String authErrorMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'] as String;
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach server. Check Docker is running and API URL is correct.';
    }
  }
  return error.toString().replaceFirst('Exception: ', '');
}
