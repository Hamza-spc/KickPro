import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final matchRatingsProvider = FutureProvider.autoDispose.family<List<PlayerMatchRating>, int>((ref, matchId) {
  return ref.read(matchRepositoryProvider).getMatchRatings(matchId);
});

class MatchRatingScreen extends ConsumerStatefulWidget {
  const MatchRatingScreen({super.key, required this.matchId});

  final int matchId;

  @override
  ConsumerState<MatchRatingScreen> createState() => _MatchRatingScreenState();
}

class _MatchRatingScreenState extends ConsumerState<MatchRatingScreen> {
  FootballMatch? _match;
  int? _selectedPlayerId;
  int _performance = 3;
  int _punctuality = 3;
  int _teamwork = 3;
  int _behavior = 3;
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final match = await ref.read(matchRepositoryProvider).getMatch(widget.matchId);
      setState(() => _match = match);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedPlayerId == null) {
      showKickproToast(context, ref.tr.selectPlayerToRate, isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(matchRepositoryProvider).submitRating(
            matchId: widget.matchId,
            ratedPlayerId: _selectedPlayerId!,
            performanceScore: _performance,
            punctualityScore: _punctuality,
            teamworkScore: _teamwork,
            behaviorScore: _behavior,
          );
      ref.invalidate(matchRatingsProvider(widget.matchId));
      if (mounted) showKickproToast(context, ref.tr.ratingSubmitted);
      setState(() {
        _selectedPlayerId = null;
        _performance = 3;
        _punctuality = 3;
        _teamwork = 3;
        _behavior = 3;
      });
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingsAsync = ref.watch(matchRatingsProvider(widget.matchId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(ref.tr.ratePlayersTitle),
      ),
      body: _loading
          ? const Center(child: ShimmerBox(height: 200, width: double.infinity))
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
              : FutureBuilder(
                  future: ref.read(profileRepositoryProvider).getMyProfile(),
                  builder: (context, profileSnap) {
                    if (!profileSnap.hasData) {
                      return const Center(child: ShimmerBox(height: 80, width: double.infinity));
                    }
                    final myProfileId = profileSnap.data!.id;
                    final rateable = _match!.participants
                        .where((p) =>
                            p.status == ParticipantStatus.approved && p.playerId != myProfileId)
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Text(
                          ref.tr.howDidPerform,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ref.tr.rateInstructions,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 16),
                        ...rateable.map((p) {
                          final selected = _selectedPlayerId == p.playerId;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPlayerId = p.playerId),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? AppColors.primary : AppColors.border,
                                    width: selected ? 1.5 : 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => openPlayerProfile(context, p.playerId),
                                      child: CircleAvatar(
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          p.playerName.isNotEmpty ? p.playerName[0].toUpperCase() : '?',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => openPlayerProfile(context, p.playerId),
                                        child: Text(
                                          p.playerName,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedPlayerId != null) ...[
                          const SizedBox(height: 16),
                          _RatingSlider(
                            label: ref.tr.performance,
                            value: _performance,
                            onChanged: (v) => setState(() => _performance = v),
                          ),
                          _RatingSlider(
                            label: ref.tr.punctuality,
                            value: _punctuality,
                            onChanged: (v) => setState(() => _punctuality = v),
                          ),
                          _RatingSlider(
                            label: ref.tr.teamwork,
                            value: _teamwork,
                            onChanged: (v) => setState(() => _teamwork = v),
                          ),
                          _RatingSlider(
                            label: ref.tr.behavior,
                            value: _behavior,
                            onChanged: (v) => setState(() => _behavior = v),
                          ),
                          const SizedBox(height: 16),
                          KickproButton(label: ref.tr.submitRating, isLoading: _submitting, onPressed: _submit),
                        ],
                        const SizedBox(height: 24),
                        ratingsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (ratings) {
                            if (ratings.isEmpty) return const SizedBox.shrink();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ref.tr.submittedRatings,
                                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                ...ratings.map((r) => Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border, width: 0.5),
                                      ),
                                      child: Text(
                                        '${r.raterName} → ${r.ratedPlayerName}: '
                                        'P${r.performanceScore} Pu${r.punctualityScore} '
                                        'T${r.teamworkScore} B${r.behaviorScore}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _RatingSlider extends StatelessWidget {
  const _RatingSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              Text('$value/5', style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
      ),
    );
  }
}
