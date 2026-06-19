import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/search/data/search_repository.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/credibility_score_card.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final playerPreviewProvider = FutureProvider.autoDispose
    .family<({PlayerProfile profile, List<Certification> certifications}), int>((ref, profileId) async {
  final repo = ref.read(searchRepositoryProvider);
  final courseRepo = ref.read(courseRepositoryProvider);
  final results = await Future.wait([
    repo.getPlayerProfile(profileId),
    courseRepo.getPlayerCertifications(profileId),
  ]);
  return (
    profile: results[0] as PlayerProfile,
    certifications: results[1] as List<Certification>,
  );
});

Future<void> showPlayerPreviewSheet(BuildContext context, WidgetRef ref, int profileId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Consumer(
          builder: (context, ref, _) {
            final previewAsync = ref.watch(playerPreviewProvider(profileId));
            return previewAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: ShimmerBox(height: 200, width: double.infinity),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(apiErrorMessage(error), style: const TextStyle(color: AppColors.error)),
              ),
              data: (data) => _PlayerPreviewContent(
                profile: data.profile,
                certifications: data.certifications,
                scrollController: scrollController,
              ),
            );
          },
        );
      },
    ),
  );
}

class _PlayerPreviewContent extends StatelessWidget {
  const _PlayerPreviewContent({
    required this.profile,
    required this.certifications,
    required this.scrollController,
  });

  final PlayerProfile profile;
  final List<Certification> certifications;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              backgroundImage: profile.profilePhotoUrl != null
                  ? NetworkImage(profile.profilePhotoUrl!)
                  : null,
              child: profile.profilePhotoUrl == null
                  ? Text(
                      profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${profile.position.label} · ${profile.city}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CredibilityScoreCard(score: profile.credibilityScore, compact: true),
        const SizedBox(height: 16),
        _InfoTile(label: 'Preferred foot', value: profile.preferredFoot.name.toUpperCase()),
        _InfoTile(label: 'Height', value: '${profile.height} cm'),
        _InfoTile(label: 'Weight', value: '${profile.weight} kg'),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Bio', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(profile.bio!, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        ],
        if (certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('Certifications', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...certifications.map(
            (cert) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cert.courseTitle, style: const TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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
