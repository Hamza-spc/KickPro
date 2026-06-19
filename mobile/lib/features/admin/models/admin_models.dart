import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/models/user_role.dart';
import 'package:kickpro/shared/models/video_models.dart';

class AdminDashboardStats {
  const AdminDashboardStats({
    required this.totalPlayers,
    required this.pendingDrillSubmissions,
    required this.activeMatches,
    required this.totalUsers,
    required this.flaggedPosts,
  });

  final int totalPlayers;
  final int pendingDrillSubmissions;
  final int activeMatches;
  final int totalUsers;
  final int flaggedPosts;

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalPlayers: (json['totalPlayers'] as num?)?.toInt() ?? 0,
      pendingDrillSubmissions: (json['pendingDrillSubmissions'] as num?)?.toInt() ?? 0,
      activeMatches: (json['activeMatches'] as num?)?.toInt() ?? 0,
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      flaggedPosts: (json['flaggedPosts'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminStadium extends Stadium {
  const AdminStadium({
    required super.id,
    required super.name,
    required super.location,
    super.description,
    required super.pricePerHour,
    super.photos = const [],
    this.pitchCount = 1,
    this.pitchTypes = const [],
    this.openTime,
    this.closeTime,
    this.grassType,
    this.latitude,
    this.longitude,
  });

  final int pitchCount;
  final List<String> pitchTypes;
  final String? openTime;
  final String? closeTime;
  final String? grassType;
  final double? latitude;
  final double? longitude;

  factory AdminStadium.fromJson(Map<String, dynamic> json) {
    return AdminStadium(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      location: json['location'] as String,
      description: json['description'] as String?,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      photos: (json['photos'] as List<dynamic>? ?? []).cast<String>(),
      pitchCount: (json['pitchCount'] as num?)?.toInt() ?? 1,
      pitchTypes: (json['pitchTypes'] as List<dynamic>? ?? []).cast<String>(),
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      grassType: json['grassType'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'pricePerHour': pricePerHour,
      'pitchCount': pitchCount,
      'pitchTypes': pitchTypes,
      if (openTime != null) 'openTime': openTime,
      if (closeTime != null) 'closeTime': closeTime,
      if (grassType != null) 'grassType': grassType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}

class AdminDrill {
  const AdminDrill({
    required this.id,
    required this.title,
    required this.description,
    required this.rules,
    required this.level,
    required this.progressionOrder,
    this.parentDrillId,
    required this.targetSkill,
  });

  final int id;
  final String title;
  final String description;
  final String rules;
  final DrillLevel level;
  final int progressionOrder;
  final int? parentDrillId;
  final TargetSkill targetSkill;

  factory AdminDrill.fromJson(Map<String, dynamic> json) {
    return AdminDrill(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      rules: json['rules'] as String,
      level: DrillLevelApi.fromApi(json['level'] as String),
      progressionOrder: (json['progressionOrder'] as num).toInt(),
      parentDrillId: (json['parentDrillId'] as num?)?.toInt(),
      targetSkill: TargetSkillApi.fromApi(json['targetSkill'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'rules': rules,
      'level': level.apiValue,
      'progressionOrder': progressionOrder,
      'parentDrillId': parentDrillId,
      'targetSkill': targetSkill.apiValue,
    };
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.enabled,
    required this.agentVerified,
    required this.createdAt,
  });

  final int id;
  final String email;
  final UserRole role;
  final bool enabled;
  final bool agentVerified;
  final DateTime createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      role: UserRole.fromApi(json['role'] as String),
      enabled: json['enabled'] as bool? ?? true,
      agentVerified: json['agentVerified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AdminPost {
  const AdminPost({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.title,
    this.cloudinaryUrl,
    required this.postType,
    this.skillTag,
    required this.flagged,
    required this.hidden,
    required this.uploadedAt,
  });

  final int id;
  final int playerId;
  final String playerName;
  final String title;
  final String? cloudinaryUrl;
  final String postType;
  final String? skillTag;
  final bool flagged;
  final bool hidden;
  final DateTime uploadedAt;

  factory AdminPost.fromJson(Map<String, dynamic> json) {
    return AdminPost(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      title: json['title'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String?,
      postType: json['postType'] as String? ?? 'VIDEO',
      skillTag: json['skillTag'] as String?,
      flagged: json['flagged'] as bool? ?? false,
      hidden: json['hidden'] as bool? ?? false,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}

class AdminDrillSubmission {
  const AdminDrillSubmission({
    required this.id,
    required this.playerName,
    required this.drillTitle,
    required this.videoUrl,
    required this.status,
    required this.submittedAt,
  });

  final int id;
  final String playerName;
  final String drillTitle;
  final String videoUrl;
  final String status;
  final DateTime submittedAt;

  factory AdminDrillSubmission.fromJson(Map<String, dynamic> json) {
    return AdminDrillSubmission(
      id: (json['id'] as num).toInt(),
      playerName: json['playerName'] as String,
      drillTitle: json['drillTitle'] as String,
      videoUrl: json['videoCloudinaryUrl'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }
}

class AdminCourseDetail {
  const AdminCourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.lessons,
  });

  final int id;
  final String title;
  final String description;
  final DrillLevel level;
  final List<AdminLessonSummary> lessons;

  factory AdminCourseDetail.fromJson(Map<String, dynamic> json) {
    return AdminCourseDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      level: DrillLevelApi.fromApi(json['level'] as String),
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((e) => AdminLessonSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminLessonSummary {
  const AdminLessonSummary({
    required this.id,
    required this.title,
    required this.orderIndex,
    this.mediaUrl,
    this.mediaType,
  });

  final int id;
  final String title;
  final int orderIndex;
  final String? mediaUrl;
  final String? mediaType;

  factory AdminLessonSummary.fromJson(Map<String, dynamic> json) {
    return AdminLessonSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
    );
  }
}
