import 'package:kickpro/shared/models/profile_models.dart';

class PagedPlayers {
  final List<PlayerSearchResult> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final int size;

  const PagedPlayers({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  factory PagedPlayers.fromJson(Map<String, dynamic> json) {
    return PagedPlayers(
      content: (json['content'] as List<dynamic>)
          .map((item) => PlayerSearchResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: (json['totalElements'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      page: (json['number'] as num).toInt(),
      size: (json['size'] as num).toInt(),
    );
  }
}

class PlayerSearchResult {
  final int profileId;
  final String fullName;
  final String city;
  final PlayerPosition position;
  final PreferredFoot preferredFoot;
  final DateTime dateOfBirth;
  final String? profilePhotoUrl;
  final double credibilityScore;
  final int certificationCount;
  final int approvedDrillCount;
  final int approvedMatchCount;
  final double? averageDrillScore;
  final PlayerSkillsSummary? skills;

  const PlayerSearchResult({
    required this.profileId,
    required this.fullName,
    required this.city,
    required this.position,
    required this.preferredFoot,
    required this.dateOfBirth,
    required this.profilePhotoUrl,
    required this.credibilityScore,
    required this.certificationCount,
    required this.approvedDrillCount,
    required this.approvedMatchCount,
    required this.averageDrillScore,
    required this.skills,
  });

  int get age {
    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      years--;
    }
    return years;
  }

  factory PlayerSearchResult.fromJson(Map<String, dynamic> json) {
    return PlayerSearchResult(
      profileId: (json['profileId'] as num).toInt(),
      fullName: json['fullName'] as String,
      city: json['city'] as String,
      position: PlayerPositionApi.fromApi(json['position'] as String),
      preferredFoot: PreferredFootApi.fromApi(json['preferredFoot'] as String),
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      credibilityScore: (json['credibilityScore'] as num).toDouble(),
      certificationCount: (json['certificationCount'] as num).toInt(),
      approvedDrillCount: (json['approvedDrillCount'] as num).toInt(),
      approvedMatchCount: (json['approvedMatchCount'] as num?)?.toInt() ?? 0,
      averageDrillScore: json['averageDrillScore'] == null
          ? null
          : (json['averageDrillScore'] as num).toDouble(),
      skills: json['skills'] == null
          ? null
          : PlayerSkillsSummary.fromJson(json['skills'] as Map<String, dynamic>),
    );
  }
}

class PlayerSkillsSummary {
  final int dribbling;
  final int shooting;
  final int passing;
  final int speed;
  final int heading;
  final int stamina;

  const PlayerSkillsSummary({
    required this.dribbling,
    required this.shooting,
    required this.passing,
    required this.speed,
    required this.heading,
    required this.stamina,
  });

  factory PlayerSkillsSummary.fromJson(Map<String, dynamic> json) {
    return PlayerSkillsSummary(
      dribbling: (json['dribbling'] as num).toInt(),
      shooting: (json['shooting'] as num).toInt(),
      passing: (json['passing'] as num).toInt(),
      speed: (json['speed'] as num).toInt(),
      heading: (json['heading'] as num).toInt(),
      stamina: (json['stamina'] as num).toInt(),
    );
  }
}

class PlayerSearchFilters {
  final String? name;
  final PlayerPosition? position;
  final String? city;
  final PreferredFoot? preferredFoot;
  final int? minAge;
  final int? maxAge;
  final double? minCredibility;
  final int? minDrillScore;
  final bool? hasCertification;

  const PlayerSearchFilters({
    this.name,
    this.position,
    this.city,
    this.preferredFoot,
    this.minAge,
    this.maxAge,
    this.minCredibility,
    this.minDrillScore,
    this.hasCertification,
  });

  Map<String, dynamic> toQueryParameters({required int page, required int size}) {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (name != null && name!.trim().isNotEmpty) params['name'] = name!.trim();
    if (position != null) params['position'] = position!.apiValue;
    if (city != null && city!.trim().isNotEmpty) params['city'] = city!.trim();
    if (preferredFoot != null) params['preferredFoot'] = preferredFoot!.apiValue;
    if (minAge != null) params['minAge'] = minAge;
    if (maxAge != null) params['maxAge'] = maxAge;
    if (minCredibility != null) params['minCredibility'] = minCredibility;
    if (minDrillScore != null) params['minDrillScore'] = minDrillScore;
    if (hasCertification != null) params['hasCertification'] = hasCertification;
    return params;
  }

  @override
  bool operator ==(Object other) {
    return other is PlayerSearchFilters &&
        other.name == name &&
        other.position == position &&
        other.city == city &&
        other.preferredFoot == preferredFoot &&
        other.minAge == minAge &&
        other.maxAge == maxAge &&
        other.minCredibility == minCredibility &&
        other.minDrillScore == minDrillScore &&
        other.hasCertification == hasCertification;
  }

  @override
  int get hashCode => Object.hash(
        name,
        position,
        city,
        preferredFoot,
        minAge,
        maxAge,
        minCredibility,
        minDrillScore,
        hasCertification,
      );
}
