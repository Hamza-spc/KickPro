class PlayerSkills {
  final int id;
  final int playerId;
  final int dribbling;
  final int shooting;
  final int passing;
  final int speed;
  final int heading;
  final int stamina;
  final List<String> strengths;
  final List<String> weaknesses;

  const PlayerSkills({
    required this.id,
    required this.playerId,
    required this.dribbling,
    required this.shooting,
    required this.passing,
    required this.speed,
    required this.heading,
    required this.stamina,
    required this.strengths,
    required this.weaknesses,
  });

  factory PlayerSkills.fromJson(Map<String, dynamic> json) {
    return PlayerSkills(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      dribbling: (json['dribbling'] as num).toInt(),
      shooting: (json['shooting'] as num).toInt(),
      passing: (json['passing'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      heading: (json['heading'] as num).toInt(),
      stamina: (json['stamina'] as num).toInt(),
      strengths: (json['strengths'] as List<dynamic>? ?? []).cast<String>(),
      weaknesses: (json['weaknesses'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dribbling': dribbling,
      'shooting': shooting,
      'passing': passing,
      'speed': speed,
      'heading': heading,
      'stamina': stamina,
    };
  }
}
