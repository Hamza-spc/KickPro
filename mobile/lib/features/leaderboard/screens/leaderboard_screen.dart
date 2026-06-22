import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/leaderboard/data/leaderboard_repository.dart';
import 'package:kickpro/features/leaderboard/models/leaderboard_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardType _type = LeaderboardType.matches;
  PlayerPosition? _position;
  LeaderboardAgeGroup? _ageGroup;
  final _cityCtrl = TextEditingController();

  LeaderboardQuery get _query => LeaderboardQuery(
        type: _type,
        position: _position,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        ageGroup: _ageGroup,
      );

  @override
  void dispose() {
    _cityCtrl.dispose();
    super.dispose();
  }

  String _metricLabel(LeaderboardEntry entry) {
    return switch (_type) {
      LeaderboardType.matches => ref.tr.nMatches(entry.metricValue.toInt()),
      LeaderboardType.badges => ref.tr.nBadges(entry.metricValue.toInt()),
      LeaderboardType.ratings => entry.metricValue.toStringAsFixed(1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(leaderboardProvider(_query));

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
                      ref.tr.leaderboardTitle,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _TypeTab(
                    label: ref.tr.mostMatches,
                    selected: _type == LeaderboardType.matches,
                    onTap: () => setState(() => _type = LeaderboardType.matches),
                  ),
                  const SizedBox(width: 8),
                  _TypeTab(
                    label: ref.tr.mostBadges,
                    selected: _type == LeaderboardType.badges,
                    onTap: () => setState(() => _type = LeaderboardType.badges),
                  ),
                  const SizedBox(width: 8),
                  _TypeTab(
                    label: ref.tr.bestRated,
                    selected: _type == LeaderboardType.ratings,
                    onTap: () => setState(() => _type = LeaderboardType.ratings),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(ref.tr.filterByPosition,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: ref.tr.allPositions,
                    selected: _position == null,
                    onTap: () => setState(() => _position = null),
                  ),
                  ...PlayerPosition.values.map(
                    (pos) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _FilterChip(
                        label: ref.tr.positionLabel(pos),
                        selected: _position == pos,
                        onTap: () => setState(() => _position = pos),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(ref.tr.filterByAgeGroup,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _FilterChip(
                    label: ref.tr.allAgeGroups,
                    selected: _ageGroup == null,
                    onTap: () => setState(() => _ageGroup = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: ref.tr.ageGroupU18,
                    selected: _ageGroup == LeaderboardAgeGroup.u18,
                    onTap: () => setState(() => _ageGroup = LeaderboardAgeGroup.u18),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: ref.tr.ageGroupU21,
                    selected: _ageGroup == LeaderboardAgeGroup.u21,
                    onTap: () => setState(() => _ageGroup = LeaderboardAgeGroup.u21),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: ref.tr.ageGroupOpen,
                    selected: _ageGroup == LeaderboardAgeGroup.open,
                    onTap: () => setState(() => _ageGroup = LeaderboardAgeGroup.open),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _cityCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: ref.tr.allCities,
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.location_city, color: AppColors.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(leaderboardProvider(_query)),
                child: entriesAsync.when(
                  loading: () => ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: ShimmerBox(height: 72, width: double.infinity),
                      ),
                    ],
                  ),
                  error: (e, _) => ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          apiErrorMessage(e),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              ref.tr.noPlayersRanked,
                              style: const TextStyle(color: AppColors.textHint),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: entries.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        return _LeaderboardCard(
                          entry: entry,
                          metricLabel: _metricLabel(entry),
                          onTap: () => openPlayerProfile(context, entry.playerId),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  const _TypeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({
    required this.entry,
    required this.metricLabel,
    required this.onTap,
  });

  final LeaderboardEntry entry;
  final String metricLabel;
  final VoidCallback onTap;

  Color get _rankColor {
    return switch (entry.rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textHint,
    };
  }

  @override
  Widget build(BuildContext context) {
    final topThree = entry.rank <= 3;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: topThree ? _rankColor.withValues(alpha: 0.6) : AppColors.border,
              width: topThree ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    color: _rankColor,
                    fontWeight: FontWeight.w700,
                    fontSize: topThree ? 18 : 15,
                  ),
                ),
              ),
              KickproAvatar(
                radius: 22,
                photoUrl: entry.profilePhotoUrl,
                name: entry.playerName,
                backgroundColor: AppColors.background,
                fallbackTextColor: AppColors.textPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.playerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (entry.city.isNotEmpty)
                      Text(entry.city, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                metricLabel,
                style: TextStyle(
                  color: topThree ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
