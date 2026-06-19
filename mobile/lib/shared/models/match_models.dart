enum MatchStatus {
  open('OPEN'),
  full('FULL'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const MatchStatus(this.apiValue);
  final String apiValue;

  static MatchStatus fromApi(String value) =>
      MatchStatus.values.firstWhere((e) => e.apiValue == value, orElse: () => MatchStatus.open);
}

enum MatchGender {
  maleOnly('MALE_ONLY'),
  femaleOnly('FEMALE_ONLY'),
  mixed('MIXED');

  const MatchGender(this.apiValue);
  final String apiValue;

  static MatchGender fromApi(String value) =>
      MatchGender.values.firstWhere((e) => e.apiValue == value, orElse: () => MatchGender.mixed);

  String get label => switch (this) {
        MatchGender.maleOnly => 'Men only',
        MatchGender.femaleOnly => 'Women only',
        MatchGender.mixed => 'Mixed',
      };
}

enum ParticipantStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const ParticipantStatus(this.apiValue);
  final String apiValue;

  static ParticipantStatus fromApi(String value) => ParticipantStatus.values
      .firstWhere((e) => e.apiValue == value, orElse: () => ParticipantStatus.pending);
}

class Stadium {
  const Stadium({
    required this.id,
    required this.name,
    required this.location,
    this.phoneNumber,
    this.description,
    required this.pricePerHour,
    this.photos = const [],
  });

  final int id;
  final String name;
  final String location;
  final String? phoneNumber;
  final String? description;
  final double pricePerHour;
  final List<String> photos;

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id'] as int,
      name: json['name'] as String,
      location: json['location'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      description: json['description'] as String?,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}

class MatchParticipant {
  const MatchParticipant({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.profilePhotoUrl,
    required this.status,
    required this.joinedAt,
  });

  final int id;
  final int playerId;
  final String playerName;
  final String? profilePhotoUrl;
  final ParticipantStatus status;
  final DateTime joinedAt;

  factory MatchParticipant.fromJson(Map<String, dynamic> json) {
    return MatchParticipant(
      id: json['id'] as int,
      playerId: json['playerId'] as int,
      playerName: json['playerName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      status: ParticipantStatus.fromApi(json['status'] as String),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}

class FootballMatch {
  const FootballMatch({
    required this.id,
    required this.stadiumId,
    required this.stadiumName,
    required this.stadiumLocation,
    required this.organizerId,
    required this.organizerName,
    required this.dateTime,
    required this.maxPlayers,
    required this.minAge,
    required this.maxAge,
    required this.gender,
    required this.city,
    required this.approvedCount,
    required this.status,
    this.chatRoomId,
    this.participants = const [],
  });

  final int id;
  final int stadiumId;
  final String stadiumName;
  final String stadiumLocation;
  final int organizerId;
  final String organizerName;
  final DateTime dateTime;
  final int maxPlayers;
  final int minAge;
  final int maxAge;
  final MatchGender gender;
  final String city;
  final int approvedCount;
  final MatchStatus status;
  final int? chatRoomId;
  final List<MatchParticipant> participants;

  bool get isFull => status == MatchStatus.full;
  bool get isCompleted => status == MatchStatus.completed;
  bool get isOpen => status == MatchStatus.open;

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: json['id'] as int,
      stadiumId: json['stadiumId'] as int,
      stadiumName: json['stadiumName'] as String,
      stadiumLocation: json['stadiumLocation'] as String,
      organizerId: json['organizerId'] as int,
      organizerName: json['organizerName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      maxPlayers: json['maxPlayers'] as int,
      minAge: (json['minAge'] as num?)?.toInt() ?? 16,
      maxAge: (json['maxAge'] as num?)?.toInt() ?? 99,
      gender: MatchGender.fromApi(json['gender'] as String? ?? 'MIXED'),
      city: json['city'] as String? ?? '',
      approvedCount: json['approvedCount'] as int,
      status: MatchStatus.fromApi(json['status'] as String),
      chatRoomId: json['chatRoomId'] as int?,
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) => MatchParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.matchId,
    required this.senderId,
    this.senderProfileId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  final int id;
  final int roomId;
  final int matchId;
  final int senderId;
  final int? senderProfileId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      roomId: json['roomId'] as int,
      matchId: json['matchId'] as int,
      senderId: json['senderId'] as int,
      senderProfileId: (json['senderProfileId'] as num?)?.toInt(),
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }
}

class PlayerMatchRating {
  const PlayerMatchRating({
    required this.id,
    required this.matchId,
    required this.raterId,
    required this.raterName,
    required this.ratedPlayerId,
    required this.ratedPlayerName,
    required this.performanceScore,
    required this.punctualityScore,
    required this.teamworkScore,
    required this.behaviorScore,
    required this.ratedAt,
  });

  final int id;
  final int matchId;
  final int raterId;
  final String raterName;
  final int ratedPlayerId;
  final String ratedPlayerName;
  final int performanceScore;
  final int punctualityScore;
  final int teamworkScore;
  final int behaviorScore;
  final DateTime ratedAt;

  factory PlayerMatchRating.fromJson(Map<String, dynamic> json) {
    return PlayerMatchRating(
      id: json['id'] as int,
      matchId: json['matchId'] as int,
      raterId: json['raterId'] as int,
      raterName: json['raterName'] as String,
      ratedPlayerId: json['ratedPlayerId'] as int,
      ratedPlayerName: json['ratedPlayerName'] as String,
      performanceScore: json['performanceScore'] as int,
      punctualityScore: json['punctualityScore'] as int,
      teamworkScore: json['teamworkScore'] as int,
      behaviorScore: json['behaviorScore'] as int,
      ratedAt: DateTime.parse(json['ratedAt'] as String),
    );
  }
}
