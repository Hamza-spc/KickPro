import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/drills/data/drill_repository.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/models/video_models.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final drillProgressionProvider = FutureProvider.autoDispose
    .family<List<DrillProgressionItem>, DrillLevel>((ref, level) {
  return ref.read(drillRepositoryProvider).getProgression(level);
});

final playerBadgesProvider = FutureProvider.autoDispose<List<PlayerBadge>>((ref) {
  return ref.read(drillRepositoryProvider).getMyBadges();
});

class DrillProgressionScreen extends ConsumerStatefulWidget {
  const DrillProgressionScreen({super.key});

  @override
  ConsumerState<DrillProgressionScreen> createState() => _DrillProgressionScreenState();
}

class _DrillProgressionScreenState extends ConsumerState<DrillProgressionScreen> {
  DrillLevel _level = DrillLevel.beginner;

  @override
  Widget build(BuildContext context) {
    final progressionAsync = ref.watch(drillProgressionProvider(_level));
    final badgesAsync = ref.watch(playerBadgesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(drillProgressionProvider(_level));
            ref.invalidate(playerBadgesProvider);
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Drill Progression',
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/ai/coach'),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('AI Coach'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size.fromHeight(44),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: DrillLevel.values.map((level) {
                      final selected = level == _level;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _level = level),
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : AppColors.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                              ),
                              child: Text(
                                level.label,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              badgesAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (badges) {
                  if (badges.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: badges
                            .map((badge) => Chip(
                                  avatar: const Icon(Icons.emoji_events, color: AppColors.gold, size: 16),
                                  label: Text(badge.drillTitle, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: AppColors.surface,
                                ))
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              progressionAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 240, width: double.infinity),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(e.toString(), style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (items) => SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _DrillTile(item: items[index]),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrillTile extends StatelessWidget {
  const _DrillTile({required this.item});
  final DrillProgressionItem item;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (item.status) {
      DrillProgressStatus.completed => (Icons.check_circle, AppColors.success, 'Completed'),
      DrillProgressStatus.current => (Icons.play_circle, AppColors.primary, 'Current'),
      DrillProgressStatus.locked => (Icons.lock, AppColors.textHint, 'Locked'),
    };

    final canSubmit = item.status == DrillProgressStatus.current;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.status == DrillProgressStatus.current ? AppColors.primary : AppColors.border,
          width: item.status == DrillProgressStatus.current ? 1 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 8),
          Text('Target: ${item.targetSkill.label}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          if (canSubmit) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push('/drills/${item.id}/submit', extra: item),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Submit drill video'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
