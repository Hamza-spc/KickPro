import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/data/ai_repository.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AiTextRequest {
  const AiTextRequest({
    required this.action,
    this.videoUrl,
    this.skillTag,
  });

  final AiTextAction action;
  final String? videoUrl;
  final String? skillTag;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AiTextRequest &&
            action == other.action &&
            videoUrl == other.videoUrl &&
            skillTag == other.skillTag;
  }

  @override
  int get hashCode => Object.hash(action, videoUrl, skillTag);
}

final aiTextProvider = FutureProvider.autoDispose.family<AiTextResponse, AiTextRequest>((ref, request) {
  final repo = ref.read(aiRepositoryProvider);
  return switch (request.action) {
    AiTextAction.explainScore => repo.explainScore(),
    AiTextAction.mealPlan => repo.mealPlan(),
    AiTextAction.videoFeedback => repo.videoFeedback(
        videoUrl: request.videoUrl ?? '',
        skillTag: request.skillTag,
      ),
  };
});

class AiTextResultScreen extends ConsumerWidget {
  const AiTextResultScreen({
    super.key,
    required this.action,
    this.videoUrl,
    this.skillTag,
  });

  final AiTextAction action;
  final String? videoUrl;
  final String? skillTag;

  AiTextRequest get _request => AiTextRequest(
        action: action,
        videoUrl: videoUrl,
        skillTag: skillTag,
      );

  String _title(WidgetRef ref) => switch (action) {
        AiTextAction.explainScore => ref.tr.scoreExplanation,
        AiTextAction.mealPlan => ref.tr.mealPlan,
        AiTextAction.videoFeedback => ref.tr.videoScoutingReport,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAsync = ref.watch(aiTextProvider(_request));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  const KickproChatbotLogo(size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _title(ref),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(aiTextProvider(_request)),
                    icon: const Icon(Icons.refresh, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            Expanded(
              child: textAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ShimmerBox(height: 20, width: double.infinity),
                      SizedBox(height: 12),
                      ShimmerBox(height: 120, width: double.infinity),
                    ],
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    apiErrorMessage(error),
                    style: const TextStyle(color: AppColors.error, height: 1.4),
                  ),
                ),
                data: (data) {
                  if (data.content.trim().isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        ref.tr.aiNoResult,
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(
                        data.content,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          height: 1.5,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
