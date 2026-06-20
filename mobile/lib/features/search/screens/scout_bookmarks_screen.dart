import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/search/data/bookmark_repository.dart';
import 'package:kickpro/features/search/widgets/scout_player_card.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class ScoutBookmarksScreen extends ConsumerStatefulWidget {
  const ScoutBookmarksScreen({super.key});

  @override
  ConsumerState<ScoutBookmarksScreen> createState() => _ScoutBookmarksScreenState();
}

class _ScoutBookmarksScreenState extends ConsumerState<ScoutBookmarksScreen> {
  final Set<int> _selected = {};

  void _toggleSelection(int profileId) {
    setState(() {
      if (_selected.contains(profileId)) {
        _selected.remove(profileId);
        return;
      }
      if (_selected.length >= 2) {
        showKickproToast(context, 'You can compare up to 2 players', isError: true);
        return;
      }
      _selected.add(profileId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(scoutBookmarksProvider);
    final canCompare = _selected.length == 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.tr.bookmarks,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: canCompare
                        ? () {
                            final selectedPlayers = _selected.toList(growable: false);
                            final players = bookmarksAsync.maybeWhen(data: (v) => v, orElse: () => const []);
                            if (players.isEmpty) return;
                            final a = players.firstWhere((p) => p.profileId == selectedPlayers[0]);
                            final b = players.firstWhere((p) => p.profileId == selectedPlayers[1]);
                            context.push('/bookmarks/compare', extra: [a, b]);
                          }
                        : null,
                    icon: const Icon(Icons.compare_arrows, color: AppColors.accent),
                    label: Text('${ref.tr.compare} (${_selected.length}/2)'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(scoutBookmarksProvider);
                  ref.invalidate(scoutBookmarkIdsProvider);
                },
                child: bookmarksAsync.when(
                  loading: () => ListView(
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: ShimmerBox(height: 100, width: double.infinity),
                      ),
                    ],
                  ),
                  error: (error, _) => ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          apiErrorMessage(error),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                  data: (players) {
                    if (players.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              ref.tr.noBookmarksYet,
                              style: const TextStyle(color: AppColors.textHint),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        final selected = _selected.contains(player.profileId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Stack(
                            children: [
                              ScoutPlayerCard(
                                player: player,
                                isBookmarked: true,
                                onTap: () => _toggleSelection(player.profileId),
                                onBookmarkToggle: () async {
                                  await ref.read(bookmarkRepositoryProvider).unbookmark(player.profileId);
                                  setState(() => _selected.remove(player.profileId));
                                  ref.invalidate(scoutBookmarksProvider);
                                  ref.invalidate(scoutBookmarkIdsProvider);
                                },
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.primary : AppColors.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 0.8),
                                  ),
                                  child: Icon(
                                    selected ? Icons.check : Icons.add,
                                    size: 16,
                                    color: selected ? Colors.white : AppColors.textHint,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: IgnorePointer(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 84),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        margin: const EdgeInsets.only(right: 10, bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.22),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(Icons.open_in_new, size: 14, color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
