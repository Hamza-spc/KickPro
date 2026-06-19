enum LeaderboardType {
  matches('MATCHES'),
  badges('BADGES'),
  ratings('RATINGS');

  const LeaderboardType(this.apiValue);
  final String apiValue;
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
