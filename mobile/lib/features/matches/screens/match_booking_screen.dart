import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/features/matches/screens/book_match_flow.dart';
import 'package:kickpro/features/matches/services/match_reminder_service.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final openMatchesProvider = FutureProvider.autoDispose
    .family<List<FootballMatch>, String?>((ref, city) {
  return ref.read(matchRepositoryProvider).getOpenMatches(city: city);
});

final myMatchesProvider = FutureProvider.autoDispose<List<FootballMatch>>((ref) {
  return ref.read(matchRepositoryProvider).getMyMatches();
});

const kMatchCities = [
  'Rabat',
  'Casablanca',
  'Marrakech',
  'Fes',
  'Tanger',
  'Agadir',
  'Oujda',
  'Meknes',
];

class MatchBookingScreen extends ConsumerStatefulWidget {
  const MatchBookingScreen({super.key});

  @override
  ConsumerState<MatchBookingScreen> createState() => _MatchBookingScreenState();
}

class _MatchBookingScreenState extends ConsumerState<MatchBookingScreen> {
  int _tabIndex = 0;
  String? _selectedCity = kMatchCities.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyProfileCity());
  }

  Future<void> _applyProfileCity() async {
    try {
      final profile = await ref.read(profileRepositoryProvider).getMyProfile();
      if (!mounted) return;
      if (kMatchCities.contains(profile.city)) {
        setState(() => _selectedCity = profile.city);
      }
    } catch (_) {}
  }

  Future<void> _refresh() async {
    ref.invalidate(openMatchesProvider(_selectedCity));
    ref.invalidate(myMatchesProvider);
  }

  Future<void> _openBookSheet() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BookMatchFlowScreen(
          initialCity: _selectedCity,
          onBooked: _refresh,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myMatchesProvider, (previous, next) {
      next.whenData((matches) async {
        try {
          final profile = await ref.read(profileRepositoryProvider).getMyProfile();
          await ref.read(matchReminderServiceProvider).syncApprovedMatches(
                matches: matches,
                myProfileId: profile.id,
              );
        } catch (_) {}
      });
    });

    final matchesAsync = _tabIndex == 0
        ? ref.watch(openMatchesProvider(_selectedCity))
        : ref.watch(myMatchesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBookSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(ref.tr.bookMatch, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          ref.tr.matches,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/announcements'),
                        icon: const Icon(Icons.campaign_outlined, color: AppColors.accent),
                        tooltip: ref.tr.announcements,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _TabChip(
                        label: ref.tr.open,
                        selected: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabChip(
                        label: ref.tr.myMatches,
                        selected: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabIndex == 0) ...[
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: kMatchCities.map((city) {
                        final selected = _selectedCity == city;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _TabChip(
                            label: city,
                            selected: selected,
                            onTap: () => setState(() => _selectedCity = city),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              matchesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 120, width: double.infinity),
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(error.toString(), style: const TextStyle(color: AppColors.error)),
                        const SizedBox(height: 12),
                        KickproButton(label: ref.tr.retry, onPressed: _refresh),
                      ],
                    ),
                  ),
                ),
                data: (matches) {
                  if (matches.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              _tabIndex == 0 ? Icons.sports_soccer_outlined : Icons.event_busy_outlined,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _tabIndex == 0
                                  ? ref.tr.noOpenMatches
                                  : ref.tr.noMyMatches,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _MatchCard(
                          match: matches[index],
                          onTap: () => context.push('/matches/${matches[index].id}'),
                        ),
                      ),
                      childCount: matches.length,
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.onTap});

  final FootballMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = match.dateTime;
    final dateLabel =
        '${date.day}/${date.month}/${date.year} · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final cover = match.stadiumCoverPhotoUrl;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null && cover.isNotEmpty)
                      Image.network(cover, fit: BoxFit.cover)
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A2744), Color(0xFF0D2137)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.stadium_outlined, color: AppColors.textHint, size: 34),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      top: 12,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.stadiumName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StatusBadge(status: match.status),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          _AvatarStack(count: match.approvedCount, max: match.maxPlayers, compact: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.stadiumLocation,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${context.tr.agesRange(match.minAge, match.maxAge)} · ${context.tr.matchGenderLabel(match.gender)}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr.organizerName(match.organizerName),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final (label, color, bg) = switch (status) {
      MatchStatus.open => (tr.statusOpen, AppColors.accent, const Color(0xFF1E3A5F)),
      MatchStatus.full => (tr.statusFull, AppColors.gold, const Color(0xFF2D1F00)),
      MatchStatus.completed => (tr.statusDone, AppColors.success, const Color(0xFF052E16)),
      MatchStatus.cancelled => (tr.statusCancelled, AppColors.error, const Color(0xFF2D0707)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count, required this.max, this.compact = false});

  final int count;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!compact)
          ...List.generate(count.clamp(0, 3), (i) {
            return Transform.translate(
              offset: Offset(-8.0 * i, 0),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            );
          }),
        if (!compact) const SizedBox(width: 4),
        if (compact)
          Transform.translate(
            offset: const Offset(0, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                '$count/$max',
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        if (!compact)
          Text('$count/$max', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
