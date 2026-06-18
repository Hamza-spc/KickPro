enum PlayerPosition { striker, midfielder, defender, goalkeeper }

enum PreferredFoot { left, right, both }

extension PlayerPositionApi on PlayerPosition {
  String get apiValue => name.toUpperCase();

  static PlayerPosition fromApi(String value) {
    return PlayerPosition.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => PlayerPosition.striker,
    );
  }

  String get label {
    return switch (this) {
      PlayerPosition.striker => 'Striker',
      PlayerPosition.midfielder => 'Midfielder',
      PlayerPosition.defender => 'Defender',
      PlayerPosition.goalkeeper => 'Goalkeeper',
    };
  }
}

extension PreferredFootApi on PreferredFoot {
  String get apiValue => name.toUpperCase();

  static PreferredFoot fromApi(String value) {
    return PreferredFoot.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => PreferredFoot.right,
    );
  }
}

class PlayerProfile {
  final int id;
  final int userId;
  final String fullName;
  final DateTime dateOfBirth;
  final String city;
  final PlayerPosition position;
  final PreferredFoot preferredFoot;
  final String? bio;
  final int height;
  final int weight;
  final String? profilePhotoUrl;
  final double credibilityScore;

  const PlayerProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.dateOfBirth,
    required this.city,
    required this.position,
    required this.preferredFoot,
    required this.bio,
    required this.height,
    required this.weight,
    required this.profilePhotoUrl,
    required this.credibilityScore,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      city: json['city'] as String,
      position: PlayerPositionApi.fromApi(json['position'] as String),
      preferredFoot: PreferredFootApi.fromApi(json['preferredFoot'] as String),
      bio: json['bio'] as String?,
      height: (json['height'] as num).toInt(),
      weight: (json['weight'] as num).toInt(),
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      credibilityScore: (json['credibilityScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'dateOfBirth': dateOfBirth.toIso8601String().split('T').first,
      'city': city,
      'position': position.apiValue,
      'preferredFoot': preferredFoot.apiValue,
      'bio': bio,
      'height': height,
      'weight': weight,
    };
  }
}
