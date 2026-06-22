import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(dio: ref.watch(apiClientProvider));
});

final conversationsProvider = FutureProvider.autoDispose<List<ConversationSummary>>((ref) {
  return ref.read(messageRepositoryProvider).getConversations();
});

final messagesWithUserProvider = FutureProvider.autoDispose.family<List<DirectMessage>, int>((ref, userId) {
  return ref.read(messageRepositoryProvider).getMessagesWithUser(userId);
});

class ConversationSummary {
  const ConversationSummary({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserEmail,
    this.otherUserPhotoUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageOwn,
  });

  final int otherUserId;
  final String otherUserName;
  final String otherUserEmail;
  final String? otherUserPhotoUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool lastMessageOwn;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    return ConversationSummary(
      otherUserId: (json['otherUserId'] as num).toInt(),
      otherUserName: json['otherUserName'] as String? ?? '',
      otherUserEmail: json['otherUserEmail'] as String? ?? '',
      otherUserPhotoUrl: json['otherUserPhotoUrl'] as String?,
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      lastMessageOwn: json['lastMessageOwn'] as bool? ?? false,
    );
  }
}

class DirectMessage {
  const DirectMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    required this.ownMessage,
  });

  final int id;
  final int senderId;
  final String content;
  final DateTime createdAt;
  final bool ownMessage;

  factory DirectMessage.fromJson(Map<String, dynamic> json) {
    return DirectMessage(
      id: (json['id'] as num).toInt(),
      senderId: (json['senderId'] as num).toInt(),
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      ownMessage: json['ownMessage'] as bool? ?? false,
    );
  }
}

class MessageRepository {
  MessageRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<ConversationSummary>> getConversations() async {
    final response = await _dio.get(ApiEndpoints.messagesConversations);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => ConversationSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<List<DirectMessage>> getMessagesWithUser(int userId) async {
    final response = await _dio.get(ApiEndpoints.messagesWithUser(userId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => DirectMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<DirectMessage> sendMessage({required int receiverId, required String content}) async {
    final response = await _dio.post(
      ApiEndpoints.messagesSend,
      data: {'receiverId': receiverId, 'content': content},
    );
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => DirectMessage.fromJson(data as Map<String, dynamic>),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }
}
