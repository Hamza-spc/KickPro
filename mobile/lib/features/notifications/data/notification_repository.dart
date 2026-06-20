import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(dio: ref.watch(apiClientProvider));
});

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.read(notificationRepositoryProvider).getNotifications();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) {
  return ref.read(notificationRepositoryProvider).getUnreadCount();
});

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String type;
  final bool read;
  final String? referenceType;
  final int? referenceId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
    required this.referenceType,
    required this.referenceId,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      read: json['read'] as bool? ?? false,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] != null ? (json['referenceId'] as num).toInt() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationRepository {
  NotificationRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<AppNotification>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.notificationsUnreadCount);
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => ((data as Map<String, dynamic>)['count'] as num).toInt(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }

  Future<void> markAllRead() async {
    await _dio.put(ApiEndpoints.notificationsReadAll);
  }
}
