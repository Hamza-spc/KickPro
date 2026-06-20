class PlayerNote {
  const PlayerNote({
    required this.id,
    required this.playerProfileId,
    required this.scoutUserId,
    required this.scoutName,
    required this.scoutEmail,
    required this.technicalAbility,
    required this.potential,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int playerProfileId;
  final int scoutUserId;
  final String scoutName;
  final String scoutEmail;
  final int technicalAbility;
  final int potential;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PlayerNote.fromJson(Map<String, dynamic> json) {
    return PlayerNote(
      id: (json['id'] as num).toInt(),
      playerProfileId: (json['playerProfileId'] as num).toInt(),
      scoutUserId: (json['scoutUserId'] as num).toInt(),
      scoutName: (json['scoutName'] as String?) ?? '',
      scoutEmail: (json['scoutEmail'] as String?) ?? '',
      technicalAbility: (json['technicalAbility'] as num).toInt(),
      potential: (json['potential'] as num).toInt(),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

