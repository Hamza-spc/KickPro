import 'package:kickpro/shared/models/video_models.dart';

enum DrillLevel { beginner, intermediate, advanced }

enum DrillProgressStatus { completed, current, locked }

extension DrillLevelApi on DrillLevel {
  String get apiValue => name.toUpperCase();

  static DrillLevel fromApi(String value) {
    return DrillLevel.values.firstWhere(
      (level) => level.apiValue == value,
      orElse: () => DrillLevel.beginner,
    );
  }

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

extension DrillProgressStatusApi on DrillProgressStatus {
  static DrillProgressStatus fromApi(String value) {
    return DrillProgressStatus.values.firstWhere(
      (status) => status.name.toUpperCase() == value,
      orElse: () => DrillProgressStatus.locked,
    );
  }
}

class DrillProgressionItem {
  final int id;
  final String title;
  final String description;
  final String rules;
  final DrillLevel level;
  final int progressionOrder;
  final int? parentDrillId;
  final TargetSkill targetSkill;
  final DrillProgressStatus status;

  const DrillProgressionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.rules,
    required this.level,
    required this.progressionOrder,
    required this.parentDrillId,
    required this.targetSkill,
    required this.status,
  });

  factory DrillProgressionItem.fromJson(Map<String, dynamic> json) {
    return DrillProgressionItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      rules: json['rules'] as String,
      level: DrillLevelApi.fromApi(json['level'] as String),
      progressionOrder: (json['progressionOrder'] as num).toInt(),
      parentDrillId: (json['parentDrillId'] as num?)?.toInt(),
      targetSkill: TargetSkillApi.fromApi(json['targetSkill'] as String),
      status: DrillProgressStatusApi.fromApi(json['status'] as String),
    );
  }
}

class PlayerBadge {
  final int id;
  final int playerId;
  final int drillId;
  final String drillTitle;
  final DateTime earnedAt;
  final String badgeType;

  const PlayerBadge({
    required this.id,
    required this.playerId,
    required this.drillId,
    required this.drillTitle,
    required this.earnedAt,
    required this.badgeType,
  });

  factory PlayerBadge.fromJson(Map<String, dynamic> json) {
    return PlayerBadge(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      drillId: (json['drillId'] as num).toInt(),
      drillTitle: json['drillTitle'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      badgeType: json['badgeType'] as String,
    );
  }
}
