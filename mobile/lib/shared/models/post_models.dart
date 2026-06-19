import 'package:kickpro/shared/models/video_models.dart';

enum PostType { video, image, text }

enum ReactionType { soccer, heart, clap }

extension PostTypeApi on PostType {
  String get apiValue => name.toUpperCase();

  static PostType fromApi(String value) {
    return PostType.values.firstWhere(
      (t) => t.apiValue == value,
      orElse: () => PostType.text,
    );
  }
}

extension ReactionTypeApi on ReactionType {
  String get apiValue => name.toUpperCase();

  static ReactionType? fromApi(String? value) {
    if (value == null) return null;
    for (final type in ReactionType.values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }

  String get emoji => switch (this) {
        ReactionType.soccer => '⚽️',
        ReactionType.heart => '❤️',
        ReactionType.clap => '👏',
      };
}

class FeedPost {
  final int id;
  final int playerId;
  final String playerName;
  final String? playerPhotoUrl;
  final String title;
  final String? cloudinaryUrl;
  final PostType postType;
  final TargetSkill? skillTag;
  final int viewsCount;
  final double averageRating;
  final DateTime uploadedAt;
  final DateTime? updatedAt;
  final bool ownPost;
  final bool followingAuthor;
  final int commentCount;
  final Map<ReactionType, int> reactionCounts;
  final ReactionType? myReaction;

  const FeedPost({
    required this.id,
    required this.playerId,
    required this.playerName,
    this.playerPhotoUrl,
    required this.title,
    this.cloudinaryUrl,
    required this.postType,
    this.skillTag,
    required this.viewsCount,
    required this.averageRating,
    required this.uploadedAt,
    this.updatedAt,
    required this.ownPost,
    required this.followingAuthor,
    required this.commentCount,
    required this.reactionCounts,
    this.myReaction,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    final countsRaw = json['reactionCounts'] as Map<String, dynamic>? ?? {};
    final counts = <ReactionType, int>{};
    for (final type in ReactionType.values) {
      counts[type] = (countsRaw[type.apiValue] as num?)?.toInt() ?? 0;
    }
    return FeedPost(
      id: (json['id'] as num).toInt(),
      playerId: (json['playerId'] as num).toInt(),
      playerName: json['playerName'] as String,
      playerPhotoUrl: json['playerPhotoUrl'] as String?,
      title: json['title'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String?,
      postType: PostTypeApi.fromApi(json['postType'] as String? ?? 'VIDEO'),
      skillTag: json['skillTag'] == null
          ? null
          : TargetSkillApi.fromApi(json['skillTag'] as String),
      viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      ownPost: json['ownPost'] as bool? ?? false,
      followingAuthor: json['followingAuthor'] as bool? ?? false,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      reactionCounts: counts,
      myReaction: ReactionTypeApi.fromApi(json['myReaction'] as String?),
    );
  }

  String get shareText {
    final tag = skillTag?.label;
    if (tag != null) {
      return '$title — $playerName ($tag) on KickPro';
    }
    return '$title — $playerName on KickPro';
  }
}

class PostComment {
  final int id;
  final int authorId;
  final int? authorProfileId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.authorId,
    this.authorProfileId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: (json['id'] as num).toInt(),
      authorId: (json['authorId'] as num).toInt(),
      authorProfileId: (json['authorProfileId'] as num?)?.toInt(),
      authorName: json['authorName'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
