import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/challenges/data/challenge_repository.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/kickpro_empty_state.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  final _videoUrlController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _videoUrlController.text.trim();
    if (url.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref.read(challengeRepositoryProvider).submit(url);
      ref.invalidate(challengeSubmissionsProvider);
      if (mounted) showKickproToast(context, ref.tr.challengeSubmitted);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _vote(int submissionId) async {
    try {
      await ref.read(challengeRepositoryProvider).vote(submissionId);
      ref.invalidate(challengeSubmissionsProvider);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challengeAsync = ref.watch(activeChallengeProvider);
    final submissionsAsync = ref.watch(challengeSubmissionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeChallengeProvider);
            ref.invalidate(challengeSubmissionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          ref.tr.weeklyChallenge,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: challengeAsync.when(
                    loading: () => const ShimmerBox(height: 140, width: double.infinity),
                    error: (e, _) => Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                    data: (challenge) {
                      if (challenge == null) {
                        return KickproEmptyState(
                          icon: Icons.emoji_events_outlined,
                          message: ref.tr.noActiveChallenge,
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  challenge.title,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  challenge.description,
                                  style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${challenge.startDate.day}/${challenge.startDate.month} – ${challenge.endDate.day}/${challenge.endDate.month}',
                                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          KickproTextField(
                            controller: _videoUrlController,
                            label: ref.tr.videoUrl,
                            hint: ref.tr.videoUrlHint,
                          ),
                          const SizedBox(height: 12),
                          KickproButton(
                            label: ref.tr.submitChallenge,
                            onPressed: _submitting ? null : _submit,
                            isLoading: _submitting,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    ref.tr.challengeSubmissions,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              submissionsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 80, width: double.infinity),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (submissions) {
                  if (submissions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: KickproEmptyState(
                        icon: Icons.videocam_outlined,
                        message: ref.tr.noChallengeSubmissions,
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final submission = submissions[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => openPlayerProfile(context, submission.playerId),
                                  child: Text(
                                    submission.playerName,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  submission.videoUrl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${submission.votes} ${ref.tr.votes}',
                                      style: const TextStyle(color: AppColors.textSecondary),
                                    ),
                                    const Spacer(),
                                    if (!submission.ownSubmission)
                                      TextButton(
                                        onPressed: () => _vote(submission.id),
                                        child: Text(ref.tr.vote),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: submissions.length,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
