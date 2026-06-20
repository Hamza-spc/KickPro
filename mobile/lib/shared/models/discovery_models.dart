import 'package:kickpro/shared/models/match_models.dart';

class DiscoveryData {
  final int playersNearby;
  final int openMatches;
  final List<FootballMatch> upcomingInCity;
  final List<DiscoveryPlayer> topPlayers;

  const DiscoveryData({
    required this.playersNearby,
    required this.openMatches,
    required this.upcomingInCity,
    required this.topPlayers,
  });

  factory DiscoveryData.fromJson(Map<String, dynamic> json) {
    return DiscoveryData(
      playersNearby: (json['playersNearby'] as num?)?.toInt() ?? 0,
      openMatches: (json['openMatches'] as num?)?.toInt() ?? 0,
      upcomingInCity: (json['upcomingInCity'] as List<dynamic>? ?? [])
          .map((m) => FootballMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      topPlayers: (json['topPlayers'] as List<dynamic>? ?? [])
          .map((p) => DiscoveryPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DiscoveryPlayer {
  final int playerId;
  final String playerName;
  final String? profilePhotoUrl;
  final String city;
  final double credibilityScore;

  const DiscoveryPlayer({
    required this.playerId,
    required this.playerName,
    required this.profilePhotoUrl,
    required this.city,
    required this.credibilityScore,
  });

  factory DiscoveryPlayer.fromJson(Map<String, dynamic> json) {
    return DiscoveryPlayer(
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      city: json['city'] as String,
      credibilityScore: (json['credibilityScore'] as num).toDouble(),
    );
  }
}

class ReferralInfo {
  final String code;
  final int referralCount;
  final DateTime? appliedAt;

  const ReferralInfo({
    required this.code,
    required this.referralCount,
    this.appliedAt,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      code: json['code'] as String,
      referralCount: (json['referralCount'] as num?)?.toInt() ?? 0,
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
    );
  }
}
