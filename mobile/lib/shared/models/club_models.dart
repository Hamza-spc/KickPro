class ClubSummary {
  final int id;
  final String name;
  final String city;
  final String description;
  final String? logoUrl;
  final bool verified;
  final int ownerId;
  final String ownerName;
  final int memberCount;
  final DateTime createdAt;

  const ClubSummary({
    required this.id,
    required this.name,
    required this.city,
    required this.description,
    required this.logoUrl,
    required this.verified,
    required this.ownerId,
    required this.ownerName,
    required this.memberCount,
    required this.createdAt,
  });

  factory ClubSummary.fromJson(Map<String, dynamic> json) {
    return ClubSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      city: json['city'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String?,
      verified: json['verified'] as bool? ?? false,
      ownerId: (json['ownerId'] as num).toInt(),
      ownerName: json['ownerName'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
