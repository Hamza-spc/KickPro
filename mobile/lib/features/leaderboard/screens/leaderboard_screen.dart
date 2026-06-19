import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/leaderboard/data/leaderboard_repository.dart';
import 'package:kickpro/features/leaderboard/models/leaderboard_models.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardType _type = LeaderboardType.matches;

  String _metricLabel(LeaderboardEntry entry) {
    return switch (_type) {
      LeaderboardType.matches => '${entry.metricValue.toInt()} matches',
      LeaderboardType.badges => '${entry.metricValue.toInt()} badges',
      LeaderboardType.ratings => entry.metricValue.toStringAsFixed(1),
    };
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(leaderboardProvider(_type));

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
                  const Expanded(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  _TypeTab(
                    label: 'Most Matches',
                    selected: _type == LeaderboardType.matches,
                    onTap: () => setState(() => _type = LeaderboardType.matches),
                  ),
                  const SizedBox(width: 8),
                  _TypeTab(
                    label: 'Most Badges',
                    selected: _type == LeaderboardType.badges,
                    onTap: () => setState(() => _type = LeaderboardType.badges),
                  ),
                  const SizedBox(width: 8),
                  _TypeTab(
                    label: 'Best Rated',
                    selected: _type == LeaderboardType.ratings,
                    onTap: () => setState(() => _type = LeaderboardType.ratings),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(leaderboardProvider(_type)),
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
                        children: const [
                          SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No players ranked yet',
                              style: TextStyle(color: AppColors.textHint),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.background,
                backgroundImage: entry.profilePhotoUrl != null
                    ? NetworkImage(entry.profilePhotoUrl!)
                    : null,
                child: entry.profilePhotoUrl == null
                    ? Text(
                        entry.playerName.isNotEmpty ? entry.playerName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      )
                    : null,
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
