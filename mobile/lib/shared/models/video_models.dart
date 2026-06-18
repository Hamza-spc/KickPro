enum TargetSkill { dribbling, shooting, passing, speed, heading, stamina }

extension TargetSkillApi on TargetSkill {
  String get apiValue => name.toUpperCase();

  static TargetSkill fromApi(String value) {
    return TargetSkill.values.firstWhere(
      (skill) => skill.apiValue == value,
      orElse: () => TargetSkill.dribbling,
    );
  }

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

class PerformanceVideo {
  final int id;
  final int playerId;
  final String playerName;
  final String title;
  final String cloudinaryUrl;
  final TargetSkill skillTag;
  final int viewsCount;
  final double averageRating;
  final DateTime uploadedAt;

  const PerformanceVideo({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.title,
    required this.cloudinaryUrl,
    required this.skillTag,
    required this.viewsCount,
    required this.averageRating,
    required this.uploadedAt,
  });

  factory PerformanceVideo.fromJson(Map<String, dynamic> json) {
    return PerformanceVideo(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      title: json['title'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String,
      skillTag: TargetSkillApi.fromApi(json['skillTag'] as String),
      viewsCount: (json['viewsCount'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );
  }
}
