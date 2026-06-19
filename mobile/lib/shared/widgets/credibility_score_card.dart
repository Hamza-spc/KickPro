import 'package:flutter/material.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/shared/widgets/credibility_ring.dart';

class CredibilityScoreCard extends StatelessWidget {
  const CredibilityScoreCard({
    super.key,
    required this.score,
    this.compact = false,
  });

  final double score;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: compact
          ? Row(
              children: [
                CredibilityRing(score: score, size: 64),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credibility Score',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '0–100 trust rating for scouts',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                CredibilityRing(score: score, size: 96),
                const SizedBox(height: 12),
                const Text(
                  'Credibility Score',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your score reflects approved drills, match ratings, certifications, and match participation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                const _ScoreFactors(),
              ],
            ),
    );
  }
}

class _ScoreFactors extends StatelessWidget {
  const _ScoreFactors();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _FactorRow(icon: Icons.fitness_center, label: 'Drill scores & completions', weight: '35%'),
        _FactorRow(icon: Icons.groups, label: 'Post-match peer ratings', weight: '35%'),
        _FactorRow(icon: Icons.school, label: 'Certifications earned', weight: '15%'),
        _FactorRow(icon: Icons.sports_soccer, label: 'Match participation', weight: '10%'),
        _FactorRow(icon: Icons.play_circle_outline, label: 'Video ratings', weight: '5%'),
      ],
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({
    required this.icon,
    required this.label,
    required this.weight,
  });

  final IconData icon;
  final String label;
  final String weight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
          Text(weight, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
        ],
      ),
    );
  }
}
