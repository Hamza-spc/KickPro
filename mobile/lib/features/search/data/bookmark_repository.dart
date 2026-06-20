import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/search_models.dart';

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return BookmarkRepository(dio: ref.watch(apiClientProvider));
});

final scoutBookmarkIdsProvider = FutureProvider.autoDispose<Set<int>>((ref) {
  return ref.read(bookmarkRepositoryProvider).getBookmarkIds();
});

final scoutBookmarksProvider = FutureProvider.autoDispose<List<PlayerSearchResult>>((ref) {
  return ref.read(bookmarkRepositoryProvider).getBookmarks();
});

class BookmarkRepository {
  BookmarkRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<PlayerSearchResult>> getBookmarks() async {
    final response = await _dio.get(ApiEndpoints.scoutBookmarks);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => PlayerSearchResult.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<Set<int>> getBookmarkIds() async {
    final response = await _dio.get(ApiEndpoints.scoutBookmarkIds);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>).map((id) => (id as num).toInt()).toSet(),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<void> bookmark(int profileId) async {
    await _dio.post(ApiEndpoints.scoutBookmark(profileId));
  }

  Future<void> unbookmark(int profileId) async {
    await _dio.delete(ApiEndpoints.scoutBookmark(profileId));
  }
}
