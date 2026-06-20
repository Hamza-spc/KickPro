import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/discovery_models.dart';

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(dio: ref.watch(apiClientProvider));
});

final discoveryProvider = FutureProvider.autoDispose.family<DiscoveryData, String>((ref, city) {
  return ref.read(discoveryRepositoryProvider).getDiscovery(city);
});

final referralRepositoryProvider = Provider<ReferralRepository>((ref) {
  return ReferralRepository(dio: ref.watch(apiClientProvider));
});

final myReferralProvider = FutureProvider.autoDispose<ReferralInfo>((ref) {
  return ref.read(referralRepositoryProvider).getMyReferral();
});

class DiscoveryRepository {
  DiscoveryRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<DiscoveryData> getDiscovery(String city) async {
    final response = await _dio.get(
      ApiEndpoints.discovery,
      queryParameters: {'city': city},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => DiscoveryData.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }
}

class ReferralRepository {
  ReferralRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<ReferralInfo> getMyReferral() async {
    final response = await _dio.get(ApiEndpoints.referralsMine);
    return _parseSingle(response, ReferralInfo.fromJson);
  }

  Future<ReferralInfo> applyReferralCode(String code) async {
    final response = await _dio.post(
      ApiEndpoints.referralsApply,
      data: {'code': code.trim()},
    );
    return _parseSingle(response, ReferralInfo.fromJson);
  }

  T _parseSingle<T>(
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
    return parsed.data!;
  }
}
