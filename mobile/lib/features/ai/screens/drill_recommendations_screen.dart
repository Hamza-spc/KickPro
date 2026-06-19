import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/data/ai_repository.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final drillRecommendationsProvider = FutureProvider.autoDispose<DrillRecommendationResponse>((ref) {
  return ref.read(aiRepositoryProvider).recommendDrills();
});

class DrillRecommendationsScreen extends ConsumerWidget {
  const DrillRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(drillRecommendationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const Expanded(
                    child: Text(
                      'Recommended Drills',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(drillRecommendationsProvider),
                    icon: const Icon(Icons.refresh, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Expanded(
              child: recommendationsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: ShimmerBox(height: 200, width: double.infinity),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    apiErrorMessage(error),
                    style: const TextStyle(color: AppColors.error, height: 1.4),
                  ),
                ),
                data: (data) => ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (data.summary.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data.summary,
                          style: const TextStyle(color: AppColors.textPrimary, height: 1.4),
                        ),
                      ),
                    if (data.recommendations.isEmpty)
                      const Text(
                        'No drill recommendations right now. Complete your skills profile first.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ...data.recommendations.map(
                        (rec) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec.drillTitle,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                children: [
                                  _Tag(label: rec.targetSkill),
                                  _Tag(label: rec.level),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                rec.reason,
                                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
