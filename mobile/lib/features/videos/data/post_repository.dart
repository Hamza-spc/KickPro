import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';
import 'package:kickpro/shared/models/post_models.dart';
import 'package:kickpro/shared/models/video_models.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(dio: ref.watch(apiClientProvider));
});

final postFeedProvider = FutureProvider.autoDispose<List<FeedPost>>((ref) {
  return ref.read(postRepositoryProvider).getFeed();
});

class PostRepository {
  PostRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<FeedPost>> getFeed({int page = 0, int size = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.postFeed,
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
        .map((item) => FeedPost.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FeedPost> createPost({
    required String title,
    required PostType postType,
    TargetSkill? skillTag,
    String? filePath,
  }) async {
    final formMap = <String, dynamic>{
      'title': title,
      'postType': postType.apiValue,
    };
    if (skillTag != null) {
      formMap['skillTag'] = skillTag.apiValue;
    }
    if (filePath != null) {
      formMap['file'] = await MultipartFile.fromFile(filePath);
    }
    final response = await _dio.post(
      ApiEndpoints.posts,
      data: FormData.fromMap(formMap),
      options: Options(contentType: 'multipart/form-data'),
    );
    return _parsePost(response);
  }

  Future<FeedPost> updatePost({
    required int postId,
    required String title,
    TargetSkill? skillTag,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.post(postId),
      data: {
        'title': title,
        if (skillTag != null) 'skillTag': skillTag.apiValue,
      },
    );
    return _parsePost(response);
  }

  Future<List<PostComment>> getComments(int postId) async {
    final response = await _dio.get(ApiEndpoints.postComments(postId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data as List<dynamic>,
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!
        .map((item) => PostComment.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<PostComment> addComment({required int postId, required String text}) async {
    final response = await _dio.post(
      ApiEndpoints.postComments(postId),
      data: {'text': text},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => PostComment.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  Future<FeedPost> react({required int postId, required ReactionType reaction}) async {
    final response = await _dio.post(
      ApiEndpoints.postReactions(postId),
      data: {'reactionType': reaction.apiValue},
    );
    return _parsePost(response);
  }

  Future<void> follow(int profileId) async {
    final response = await _dio.post(ApiEndpoints.followPlayer(profileId));
    _ensureSuccess(response);
  }

  Future<void> unfollow(int profileId) async {
    final response = await _dio.delete(ApiEndpoints.followPlayer(profileId));
    _ensureSuccess(response);
  }

  FeedPost _parsePost(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => FeedPost.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) {
      throw Exception(parsed.message);
    }
    return parsed.data!;
  }

  void _ensureSuccess(Response<dynamic> response) {
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => data,
    );
    if (!parsed.success) {
      throw Exception(parsed.message);
    }
  }
}
