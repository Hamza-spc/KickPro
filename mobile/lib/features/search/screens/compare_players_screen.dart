import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/search/data/bookmark_repository.dart';
import 'package:kickpro/features/search/data/compare_repository.dart';
import 'package:kickpro/features/search/widgets/scout_player_card.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/search_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class ComparePlayersScreen extends ConsumerStatefulWidget {
  const ComparePlayersScreen({super.key, this.initialProfileA, this.initialProfileB});

  final int? initialProfileA;
  final int? initialProfileB;

  @override
  ConsumerState<ComparePlayersScreen> createState() => _ComparePlayersScreenState();
}

class _ComparePlayersScreenState extends ConsumerState<ComparePlayersScreen> {
  int? _profileA;
  int? _profileB;

  @override
  void initState() {
    super.initState();
    _profileA = widget.initialProfileA;
    _profileB = widget.initialProfileB;
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(scoutBookmarksProvider);
    final canCompare = _profileA != null && _profileB != null && _profileA != _profileB;
    final comparisonAsync = canCompare
        ? ref.watch(playerComparisonProvider((profileA: _profileA!, profileB: _profileB!)))
        : null;

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
                      ref.tr.comparePlayers,
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
            Expanded(
              child: comparisonAsync != null
                  ? comparisonAsync.when(
                      loading: () => const Center(child: ShimmerBox(height: 200, width: double.infinity)),
                      error: (e, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                        ),
                      ),
                      data: (comparison) => _ComparisonView(comparison: comparison),
                    )
                  : bookmarksAsync.when(
                      loading: () => const Center(child: ShimmerBox(height: 120, width: double.infinity)),
                      error: (e, _) => Center(
                        child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
                      ),
                      data: (players) => _PickerView(
                        players: players,
                        profileA: _profileA,
                        profileB: _profileB,
                        onSelectA: (id) => setState(() => _profileA = id),
                        onSelectB: (id) => setState(() => _profileB = id),
                        onCompare: canCompare
                            ? () => setState(() {})
                            : null,
                      ),
                    ),
            ),
            if (comparisonAsync == null && canCompare)
              Padding(
                padding: const EdgeInsets.all(16),
                child: KickproButton(
                  label: ref.tr.compare,
                  onPressed: () => setState(() {}),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickerView extends ConsumerWidget {
  const _PickerView({
    required this.players,
    required this.profileA,
    required this.profileB,
    required this.onSelectA,
    required this.onSelectB,
    required this.onCompare,
  });

  final List<PlayerSearchResult> players;
  final int? profileA;
  final int? profileB;
  final ValueChanged<int> onSelectA;
  final ValueChanged<int> onSelectB;
  final VoidCallback? onCompare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (players.isEmpty) {
      return Center(
        child: Text(ref.tr.noBookmarksYet, style: const TextStyle(color: AppColors.textHint)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(ref.tr.selectTwoPlayers, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Text('${ref.tr.playerA}: ${_label(players, profileA)}',
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        Text('${ref.tr.playerB}: ${_label(players, profileB)}',
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...players.map(
          (player) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: ScoutPlayerCard(
                    player: player,
                    isBookmarked: true,
                    onTap: () {},
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => onSelectA(player.profileId),
                      icon: Icon(
                        Icons.looks_one,
                        color: profileA == player.profileId ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
                    IconButton(
                      onPressed: () => onSelectB(player.profileId),
                      icon: Icon(
                        Icons.looks_two,
                        color: profileB == player.profileId ? AppColors.primary : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _label(List<PlayerSearchResult> players, int? id) {
    if (id == null) return '—';
    return players.firstWhere((p) => p.profileId == id, orElse: () => players.first).fullName;
  }
}

class _ComparisonView extends StatelessWidget {
  const _ComparisonView({required this.comparison});

  final PlayerComparison comparison;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CompareColumn(title: comparison.profileA.fullName, player: comparison.profileA),
        const SizedBox(height: 16),
        _CompareColumn(title: comparison.profileB.fullName, player: comparison.profileB),
      ],
    );
  }
}

class _CompareColumn extends ConsumerWidget {
  const _CompareColumn({required this.title, required this.player});

  final String title;
  final PlayerSearchResult player;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('${player.city} · ${player.position.label}',
              style: const TextStyle(color: AppColors.textSecondary)),
          Text(ref.tr.credibilityN(player.credibilityScore.round()),
              style: const TextStyle(color: AppColors.accent)),
          Text('${player.approvedDrillCount} drills · ${player.certificationCount} certs',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          if (player.averageDrillScore != null)
            Text('Avg drill: ${player.averageDrillScore!.toStringAsFixed(1)}',
                style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ),
    );
  }
}
