import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_client.dart';
import 'package:kickpro/core/api/api_endpoints.dart';
import 'package:kickpro/shared/models/api_response.dart';

final timelineRepositoryProvider = Provider<TimelineRepository>((ref) {
  return TimelineRepository(dio: ref.watch(apiClientProvider));
});

final playerTimelineProvider = FutureProvider.autoDispose.family<List<TimelineEvent>, int>((ref, profileId) {
  return ref.read(timelineRepositoryProvider).getTimeline(profileId);
});

enum TimelineEventType { drillApproved, matchParticipation, certification, post }

class TimelineEvent {
  const TimelineEvent({
    required this.type,
    required this.title,
    required this.description,
    required this.date,
  });

  final TimelineEventType type;
  final String title;
  final String description;
  final DateTime date;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      type: _parseType(json['type'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }

  static TimelineEventType _parseType(String value) {
    return switch (value) {
      'DRILL_APPROVED' => TimelineEventType.drillApproved,
      'MATCH_PARTICIPATION' => TimelineEventType.matchParticipation,
      'CERTIFICATION' => TimelineEventType.certification,
      'POST' => TimelineEventType.post,
      _ => TimelineEventType.post,
    };
  }

  IconData get icon => switch (type) {
        TimelineEventType.drillApproved => Icons.fitness_center,
        TimelineEventType.matchParticipation => Icons.sports_soccer,
        TimelineEventType.certification => Icons.verified,
        TimelineEventType.post => Icons.videocam,
      };
}

class TimelineRepository {
  TimelineRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<TimelineEvent>> getTimeline(int profileId) async {
    final response = await _dio.get(ApiEndpoints.playerTimeline(profileId));
    final parsed = ApiResponse.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List<dynamic>)
          .map((item) => TimelineEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    if (!parsed.success || parsed.data == null) throw Exception(parsed.message);
    return parsed.data!;
  }
}
