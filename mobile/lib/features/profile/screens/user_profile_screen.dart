import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/search/data/search_repository.dart';
import 'package:kickpro/features/videos/data/post_repository.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/credibility_score_card.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final viewedPlayerProfileProvider = FutureProvider.autoDispose
    .family<({PlayerProfile profile, List<Certification> certifications}), int>((ref, profileId) async {
  final results = await Future.wait([
    ref.read(searchRepositoryProvider).getPlayerProfile(profileId),
    ref.read(courseRepositoryProvider).getPlayerCertifications(profileId),
  ]);
  return (
    profile: results[0] as PlayerProfile,
    certifications: results[1] as List<Certification>,
  );
});

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key, required this.profileId});

  final int profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(viewedPlayerProfileProvider(profileId));

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: ShimmerBox(height: 200, width: double.infinity)),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(apiErrorMessage(error), style: const TextStyle(color: AppColors.error)),
            ),
          ),
          data: (data) => _UserProfileContent(
            profile: data.profile,
            certifications: data.certifications,
            onFollowChanged: () => ref.invalidate(viewedPlayerProfileProvider(profileId)),
          ),
        ),
      ),
    );
  }
}

class _UserProfileContent extends ConsumerStatefulWidget {
  const _UserProfileContent({
    required this.profile,
    required this.certifications,
    required this.onFollowChanged,
  });

  final PlayerProfile profile;
  final List<Certification> certifications;
  final VoidCallback onFollowChanged;

  @override
  ConsumerState<_UserProfileContent> createState() => _UserProfileContentState();
}

class _UserProfileContentState extends ConsumerState<_UserProfileContent> {
  late PlayerProfile _profile;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  @override
  void didUpdateWidget(covariant _UserProfileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id ||
        oldWidget.profile.following != widget.profile.following ||
        oldWidget.profile.followersCount != widget.profile.followersCount) {
      _profile = widget.profile;
    }
  }

  Future<void> _toggleFollow() async {
    setState(() => _acting = true);
    try {
      final repo = ref.read(postRepositoryProvider);
      if (_profile.following) {
        await repo.unfollow(_profile.id);
      } else {
        await repo.follow(_profile.id);
      }
      setState(() {
        _profile = PlayerProfile(
          id: _profile.id,
          userId: _profile.userId,
          fullName: _profile.fullName,
          dateOfBirth: _profile.dateOfBirth,
          city: _profile.city,
          position: _profile.position,
          preferredFoot: _profile.preferredFoot,
          bio: _profile.bio,
          height: _profile.height,
          weight: _profile.weight,
          profilePhotoUrl: _profile.profilePhotoUrl,
          credibilityScore: _profile.credibilityScore,
          followersCount: _profile.following
              ? _profile.followersCount - 1
              : _profile.followersCount + 1,
          followingCount: _profile.followingCount,
          following: !_profile.following,
          ownProfile: _profile.ownProfile,
        );
      });
      widget.onFollowChanged();
      ref.invalidate(postFeedProvider);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                Expanded(
                  child: Text(
                    _profile.fullName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  backgroundImage: _profile.profilePhotoUrl != null
                      ? NetworkImage(_profile.profilePhotoUrl!)
                      : null,
                  child: _profile.profilePhotoUrl == null
                      ? Text(
                          _profile.fullName.isNotEmpty ? _profile.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _profile.fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_profile.position.label} · ${_profile.city}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FollowStat(count: _profile.followersCount, label: 'Followers'),
                    const SizedBox(width: 32),
                    _FollowStat(count: _profile.followingCount, label: 'Following'),
                  ],
                ),
                if (!_profile.ownProfile) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 160,
                    child: KickproButton(
                      label: _profile.following ? 'Following' : 'Follow',
                      onPressed: _acting ? null : _toggleFollow,
                      isLoading: _acting,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _Badge(label: _profile.position.label),
                    _Badge(label: _profile.city),
                    _Badge(label: _profile.preferredFoot.name.toUpperCase()),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CredibilityScoreCard(score: _profile.credibilityScore, compact: true),
                const SizedBox(height: 16),
                _InfoTile(label: 'Height', value: '${_profile.height} cm'),
                _InfoTile(label: 'Weight', value: '${_profile.weight} kg'),
                _InfoTile(
                  label: 'Born',
                  value:
                      '${_profile.dateOfBirth.day}/${_profile.dateOfBirth.month}/${_profile.dateOfBirth.year}',
                ),
                if (_profile.bio != null && _profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Bio', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(_profile.bio!, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
                ],
                if (widget.certifications.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Certifications',
                      style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...widget.certifications.map(
                    (cert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(cert.courseTitle,
                                style: const TextStyle(color: AppColors.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowStat extends StatelessWidget {
  const _FollowStat({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textHint)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
