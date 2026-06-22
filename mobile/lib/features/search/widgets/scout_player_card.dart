import 'package:flutter/material.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/shared/widgets/credibility_ring.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';

class ScoutPlayerCard extends StatelessWidget {
  const ScoutPlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    this.isBookmarked = false,
    this.onBookmarkToggle,
  });

  final PlayerSearchResult player;
  final VoidCallback onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              KickproAvatar(
                radius: 24,
                photoUrl: player.profilePhotoUrl,
                name: player.fullName,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.fullName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${context.tr.positionLabel(player.position)} · ${player.city} · ${context.tr.nYearsOld(player.age)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (player.skills != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Top: Speed ${player.skills!.speed}/10 · Shooting ${player.skills!.shooting}/10',
                        style: const TextStyle(color: AppColors.textHint, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              if (onBookmarkToggle != null)
                IconButton(
                  onPressed: onBookmarkToggle,
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? AppColors.gold : AppColors.textHint,
                  ),
                ),
              CredibilityRing(score: player.credibilityScore, size: 56),
            ],
          ),
        ),
      ),
    );
  }
}
