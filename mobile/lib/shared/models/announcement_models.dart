enum AnnouncementType { trial, news, tournament, officialTrial }

extension AnnouncementTypeApi on AnnouncementType {
  String get apiValue => switch (this) {
        AnnouncementType.trial => 'TRIAL',
        AnnouncementType.news => 'NEWS',
        AnnouncementType.tournament => 'TOURNAMENT',
        AnnouncementType.officialTrial => 'OFFICIAL_TRIAL',
      };

  static AnnouncementType fromApi(String value) {
    return AnnouncementType.values.firstWhere(
      (t) => t.apiValue == value,
      orElse: () => AnnouncementType.news,
    );
  }

  String get label => switch (this) {
        AnnouncementType.trial => 'Trial',
        AnnouncementType.news => 'News',
        AnnouncementType.tournament => 'Tournament',
        AnnouncementType.officialTrial => 'Official Trial',
      };
}

class Announcement {
  final int id;
  final String title;
  final String content;
  final AnnouncementType type;
  final String? city;
  final String? imageUrl;
  final String authorName;
  final String authorRole;
  final bool official;
  final bool ownAnnouncement;
  final DateTime createdAt;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.city,
    required this.imageUrl,
    required this.authorName,
    required this.authorRole,
    required this.official,
    required this.ownAnnouncement,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      type: AnnouncementTypeApi.fromApi(json['type'] as String),
      city: json['city'] as String?,
      imageUrl: json['imageUrl'] as String?,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String,
      official: json['official'] as bool? ?? false,
      ownAnnouncement: json['ownAnnouncement'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CreateAnnouncementRequest {
  final String title;
  final String content;
  final AnnouncementType type;
  final String? city;

  const CreateAnnouncementRequest({
    required this.title,
    required this.content,
    required this.type,
    this.city,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'type': type.apiValue,
        if (city != null && city!.isNotEmpty) 'city': city,
      };
}
