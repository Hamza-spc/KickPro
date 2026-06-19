import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/data/ai_repository.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final aiTextProvider = FutureProvider.autoDispose.family<AiTextResponse, AiTextAction>((ref, action) {
  final repo = ref.read(aiRepositoryProvider);
  return switch (action) {
    AiTextAction.explainScore => repo.explainScore(),
    AiTextAction.mealPlan => repo.mealPlan(),
  };
});

class AiTextResultScreen extends ConsumerWidget {
  const AiTextResultScreen({super.key, required this.action});

  final AiTextAction action;

  String get _title => switch (action) {
        AiTextAction.explainScore => 'Score Explanation',
        AiTextAction.mealPlan => 'Meal Plan',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textAsync = ref.watch(aiTextProvider(action));

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
                  Expanded(
                    child: Text(
                      _title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.invalidate(aiTextProvider(action)),
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
                data: (data) => SingleChildScrollView(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
