import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/features/matches/screens/book_match_flow.dart';
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
  String? _selectedCity;
  bool _cityInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDefaultCity());
  }

  Future<void> _loadDefaultCity() async {
    if (_cityInitialized) return;
    try {
      final profile = await ref.read(profileRepositoryProvider).getMyProfile();
      if (!mounted) return;
      setState(() {
        _selectedCity = kMatchCities.contains(profile.city) ? profile.city : kMatchCities.first;
        _cityInitialized = true;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedCity = kMatchCities.first;
          _cityInitialized = true;
        });
      }
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(openMatchesProvider(_selectedCity));
    ref.invalidate(myMatchesProvider);
  }

  Future<void> _openBookSheet() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => BookMatchFlowScreen(onBooked: _refresh),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = _tabIndex == 0
        ? (_cityInitialized
            ? ref.watch(openMatchesProvider(_selectedCity))
            : const AsyncLoading<List<FootballMatch>>())
        : ref.watch(myMatchesProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openBookSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Book Match', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Matches',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _TabChip(
                        label: 'Open',
                        selected: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _TabChip(
                        label: 'My Matches',
                        selected: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                    ],
                  ),
                ),
              ),
              if (_tabIndex == 0 && _cityInitialized) ...[
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
                        KickproButton(label: 'Retry', onPressed: _refresh),
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
                                  ? 'No open matches nearby yet.\nBe the first to book one!'
                                  : 'You have no matches yet.\nTap Book Match to create one.',
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.stadiumName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: match.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(match.stadiumLocation, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              'Ages ${match.minAge}–${match.maxAge} · ${match.gender.label}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(dateLabel, style: const TextStyle(color: AppColors.accent, fontSize: 12)),
                const Spacer(),
                _AvatarStack(count: match.approvedCount, max: match.maxPlayers),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Organizer: ${match.organizerName}',
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
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
    final (label, color, bg) = switch (status) {
      MatchStatus.open => ('OPEN', AppColors.accent, const Color(0xFF1E3A5F)),
      MatchStatus.full => ('FULL', AppColors.gold, const Color(0xFF2D1F00)),
      MatchStatus.completed => ('DONE', AppColors.success, const Color(0xFF052E16)),
      MatchStatus.cancelled => ('CANCELLED', AppColors.error, const Color(0xFF2D0707)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.count, required this.max});

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
        const SizedBox(width: 4),
        Text('$count/$max', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
