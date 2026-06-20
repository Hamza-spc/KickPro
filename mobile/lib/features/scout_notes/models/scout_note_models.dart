class ScoutNote {
  const ScoutNote({
    required this.id,
    required this.playerProfileId,
    required this.technicalAbility,
    required this.potential,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int playerProfileId;
  final int technicalAbility;
  final int potential;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ScoutNote.fromJson(Map<String, dynamic> json) {
    return ScoutNote(
      id: (json['id'] as num).toInt(),
      playerProfileId: (json['playerProfileId'] as num).toInt(),
      technicalAbility: (json['technicalAbility'] as num).toInt(),
      potential: (json['potential'] as num).toInt(),
      note: json['note'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
