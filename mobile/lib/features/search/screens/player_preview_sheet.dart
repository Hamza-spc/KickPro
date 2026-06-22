import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/search/data/search_repository.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/credibility_score_card.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';
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
  openPlayerProfile(context, profileId);
  return Future.value();
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
            KickproAvatar(
              radius: 28,
              photoUrl: profile.profilePhotoUrl,
              name: profile.fullName,
              fallbackFontSize: 22,
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
                    '${context.tr.positionLabel(profile.position)} · ${profile.city}',
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
        _InfoTile(label: context.tr.preferredFoot, value: context.tr.preferredFootLabel(profile.preferredFoot)),
        _InfoTile(label: context.tr.height, value: '${profile.height} cm'),
        _InfoTile(label: context.tr.weight, value: '${profile.weight} kg'),
        if (profile.bio != null && profile.bio!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(context.tr.bio, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(profile.bio!, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
        ],
        if (certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(context.tr.certifications, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
