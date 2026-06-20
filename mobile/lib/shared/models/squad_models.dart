class SquadSummary {
  final int id;
  final String name;
  final String city;
  final int captainId;
  final String captainName;
  final String? captainPhotoUrl;
  final bool ownSquad;
  final int memberCount;
  final List<SquadMember> members;
  final DateTime createdAt;

  const SquadSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.captainId,
    required this.captainName,
    required this.captainPhotoUrl,
    required this.ownSquad,
    required this.memberCount,
    required this.members,
    required this.createdAt,
  });

  factory SquadSummary.fromJson(Map<String, dynamic> json) {
    return SquadSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      city: json['city'] as String,
      captainId: (json['captainId'] as num).toInt(),
      captainName: json['captainName'] as String,
      captainPhotoUrl: json['captainPhotoUrl'] as String?,
      ownSquad: json['ownSquad'] as bool? ?? false,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((m) => SquadMember.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SquadDiscoverItem {
  const SquadDiscoverItem({
    required this.id,
    required this.name,
    required this.city,
    required this.captainName,
    required this.memberCount,
    required this.joinState,
  });

  final int id;
  final String name;
  final String city;
  final String captainName;
  final int memberCount;
  final String joinState;

  factory SquadDiscoverItem.fromJson(Map<String, dynamic> json) {
    return SquadDiscoverItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      city: json['city'] as String,
      captainName: json['captainName'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      joinState: json['joinState'] as String? ?? 'NONE',
    );
  }
}

class SquadJoinRequestItem {
  const SquadJoinRequestItem({
    required this.id,
    required this.squadId,
    required this.squadName,
    required this.squadCity,
    required this.playerProfileId,
    required this.playerName,
    required this.playerPhotoUrl,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int squadId;
  final String squadName;
  final String squadCity;
  final int playerProfileId;
  final String playerName;
  final String? playerPhotoUrl;
  final String status;
  final DateTime createdAt;

  factory SquadJoinRequestItem.fromJson(Map<String, dynamic> json) {
    return SquadJoinRequestItem(
      id: (json['id'] as num).toInt(),
      squadId: (json['squadId'] as num).toInt(),
      squadName: json['squadName'] as String,
      squadCity: json['squadCity'] as String,
      playerProfileId: (json['playerProfileId'] as num).toInt(),
      playerName: json['playerName'] as String,
      playerPhotoUrl: json['playerPhotoUrl'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class SquadMember {
  final int id;
  final int playerId;
  final String playerName;
  final String? profilePhotoUrl;
  final DateTime joinedAt;

  const SquadMember({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.profilePhotoUrl,
    required this.joinedAt,
  });

  factory SquadMember.fromJson(Map<String, dynamic> json) {
    return SquadMember(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
