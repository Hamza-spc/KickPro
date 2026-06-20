import 'package:kickpro/shared/models/profile_models.dart';

enum LeaderboardType {
  matches('MATCHES'),
  badges('BADGES'),
  ratings('RATINGS');

  const LeaderboardType(this.apiValue);
  final String apiValue;
}

enum LeaderboardAgeGroup {
  u18('U18'),
  u21('U21'),
  open('OPEN');

  const LeaderboardAgeGroup(this.apiValue);
  final String apiValue;
}

class LeaderboardQuery {
  const LeaderboardQuery({
    required this.type,
    this.position,
    this.city,
    this.ageGroup,
  });

  final LeaderboardType type;
  final PlayerPosition? position;
  final String? city;
  final LeaderboardAgeGroup? ageGroup;

  LeaderboardQuery copyWith({
    LeaderboardType? type,
    PlayerPosition? position,
    String? city,
    LeaderboardAgeGroup? ageGroup,
    bool clearPosition = false,
    bool clearCity = false,
    bool clearAgeGroup = false,
  }) {
    return LeaderboardQuery(
      type: type ?? this.type,
      position: clearPosition ? null : (position ?? this.position),
      city: clearCity ? null : (city ?? this.city),
      ageGroup: clearAgeGroup ? null : (ageGroup ?? this.ageGroup),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LeaderboardQuery &&
        other.type == type &&
        other.position == position &&
        other.city == city &&
        other.ageGroup == ageGroup;
  }

  @override
  int get hashCode => Object.hash(type, position, city, ageGroup);
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.playerName,
    this.profilePhotoUrl,
    required this.city,
    required this.metricValue,
  });

  final int rank;
  final int playerId;
  final String playerName;
  final String? profilePhotoUrl;
  final String city;
  final double metricValue;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: (json['rank'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      city: json['city'] as String? ?? '',
      metricValue: (json['metricValue'] as num).toDouble(),
    );
  }
}
