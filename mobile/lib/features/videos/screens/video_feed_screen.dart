import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/videos/data/post_repository.dart';
import 'package:kickpro/features/videos/screens/comments_sheet.dart';
import 'package:kickpro/features/videos/widgets/post_video_player.dart';
import 'package:kickpro/shared/models/post_models.dart';
import 'package:kickpro/shared/models/video_models.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:share_plus/share_plus.dart';

class VideoFeedScreen extends ConsumerWidget {
  const VideoFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(postFeedProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(postFeedProvider),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Feed',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              feedAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 200, width: double.infinity),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (posts) {
                  if (posts.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No posts yet. Tap + to share your first update.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PostCard(post: posts[index]),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class PostCard extends ConsumerStatefulWidget {
  const PostCard({super.key, required this.post});

  final FeedPost post;

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late FeedPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  Future<void> _react(ReactionType type) async {
    try {
      final updated = await ref.read(postRepositoryProvider).react(postId: _post.id, reaction: type);
      setState(() => _post = updated);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    }
  }

  Future<void> _toggleFollow() async {
    try {
      if (_post.followingAuthor) {
        await ref.read(postRepositoryProvider).unfollow(_post.playerId);
      } else {
        await ref.read(postRepositoryProvider).follow(_post.playerId);
      }
      setState(() => _post = FeedPost(
            id: _post.id,
            playerId: _post.playerId,
            playerName: _post.playerName,
            playerPhotoUrl: _post.playerPhotoUrl,
            title: _post.title,
            cloudinaryUrl: _post.cloudinaryUrl,
            postType: _post.postType,
            skillTag: _post.skillTag,
            viewsCount: _post.viewsCount,
            averageRating: _post.averageRating,
            uploadedAt: _post.uploadedAt,
            updatedAt: _post.updatedAt,
            ownPost: _post.ownPost,
            followingAuthor: !_post.followingAuthor,
            commentCount: _post.commentCount,
            reactionCounts: _post.reactionCounts,
            myReaction: _post.myReaction,
          ));
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    }
  }

  Future<void> _share() async {
    final url = _post.cloudinaryUrl ?? '';
    await SharePlus.instance.share(ShareParams(text: '${_post.shareText}\n$url'));
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: _post.title);
    TargetSkill? skill = _post.skillTag;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Edit post', style: TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KickproTextField(controller: controller, label: 'Caption', maxLines: 3),
              if (_post.postType != PostType.text) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<TargetSkill?>(
                  value: skill,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(labelText: 'Skill tag (optional)'),
                  items: [
                    const DropdownMenuItem<TargetSkill?>(value: null, child: Text('None')),
                    ...TargetSkill.values.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    ),
                  ],
                  onChanged: (v) => skill = v,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    try {
      final updated = await ref.read(postRepositoryProvider).updatePost(
            postId: _post.id,
            title: controller.text.trim(),
            skillTag: skill,
          );
      setState(() => _post = updated);
      ref.invalidate(postFeedProvider);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => openPlayerProfile(context, _post.playerId),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        backgroundImage:
                            _post.playerPhotoUrl != null ? NetworkImage(_post.playerPhotoUrl!) : null,
                        child: _post.playerPhotoUrl == null
                            ? Text(_post.playerName.isNotEmpty ? _post.playerName[0] : '?')
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_post.playerName,
                                style: const TextStyle(
                                    color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            if (_post.skillTag != null)
                              Text(_post.skillTag!.label,
                                  style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_post.ownPost)
                TextButton(
                  onPressed: _toggleFollow,
                  child: Text(_post.followingAuthor ? 'Following' : 'Follow'),
                ),
              if (_post.ownPost)
                IconButton(
                  onPressed: _editPost,
                  icon: const Icon(Icons.edit, size: 18, color: AppColors.textHint),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_post.title, style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
          if (_post.postType == PostType.video && _post.cloudinaryUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: (MediaQuery.sizeOf(context).height * 0.75 - 220).clamp(160.0, 320.0),
              width: double.infinity,
              child: PostVideoPlayer(url: _post.cloudinaryUrl!),
            ),
          ],
          if (_post.postType == PostType.image && _post.cloudinaryUrl != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(_post.cloudinaryUrl!, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: ReactionType.values.map((type) {
              final count = _post.reactionCounts[type] ?? 0;
              final selected = _post.myReaction == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _react(type),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.25) : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text('${type.emoji} $count', style: const TextStyle(fontSize: 13)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => showCommentsSheet(context, ref, _post),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: Text('${_post.commentCount}'),
              ),
              TextButton.icon(
                onPressed: _share,
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
