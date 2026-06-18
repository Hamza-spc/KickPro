import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final openMatchesProvider = FutureProvider.autoDispose<List<FootballMatch>>((ref) {
  return ref.read(matchRepositoryProvider).getOpenMatches();
});

final myMatchesProvider = FutureProvider.autoDispose<List<FootballMatch>>((ref) {
  return ref.read(matchRepositoryProvider).getMyMatches();
});

final stadiumsProvider = FutureProvider.autoDispose<List<Stadium>>((ref) {
  return ref.read(matchRepositoryProvider).getStadiums();
});

class MatchBookingScreen extends ConsumerStatefulWidget {
  const MatchBookingScreen({super.key});

  @override
  ConsumerState<MatchBookingScreen> createState() => _MatchBookingScreenState();
}

class _MatchBookingScreenState extends ConsumerState<MatchBookingScreen> {
  int _tabIndex = 0;

  Future<void> _refresh() async {
    ref.invalidate(openMatchesProvider);
    ref.invalidate(myMatchesProvider);
  }

  Future<void> _openBookSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookMatchSheet(onBooked: () {
        _refresh();
        if (mounted) Navigator.pop(context);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesAsync = _tabIndex == 0
        ? ref.watch(openMatchesProvider)
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

class _BookMatchSheet extends ConsumerStatefulWidget {
  const _BookMatchSheet({required this.onBooked});

  final VoidCallback onBooked;

  @override
  ConsumerState<_BookMatchSheet> createState() => _BookMatchSheetState();
}

class _BookMatchSheetState extends ConsumerState<_BookMatchSheet> {
  Stadium? _selectedStadium;
  DateTime? _selectedDateTime;
  int _maxPlayers = 4;
  bool _submitting = false;

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (_selectedStadium == null || _selectedDateTime == null) {
      showKickproToast(context, 'Select a stadium and date/time', isError: true);
      return;
    }
    if (_selectedDateTime!.isBefore(DateTime.now())) {
      showKickproToast(context, 'Pick a future date and time', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(matchRepositoryProvider).createMatch(
            stadiumId: _selectedStadium!.id,
            dateTime: _selectedDateTime!,
            maxPlayers: _maxPlayers,
          );
      if (mounted) {
        showKickproToast(context, 'Match booked!');
        widget.onBooked();
      }
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stadiumsAsync = ref.watch(stadiumsProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Book a Match',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          stadiumsAsync.when(
            loading: () => const ShimmerBox(height: 80, width: double.infinity),
            error: (e, _) => Text(e.toString(), style: const TextStyle(color: AppColors.error)),
            data: (stadiums) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Stadium', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ...stadiums.map((stadium) {
                  final selected = _selectedStadium?.id == stadium.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStadium = stadium),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                            width: selected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, Color(0xFF1D4ED8)],
                                ),
                              ),
                              child: const Icon(Icons.stadium_outlined, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stadium.name,
                                      style: const TextStyle(
                                          color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                  Text(
                                    '${stadium.location} · ${stadium.pricePerHour.toStringAsFixed(0)} MAD/hr',
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (selected) const Icon(Icons.check_circle, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDateTime,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDateTime == null
                          ? 'Pick date & time'
                          : '${_selectedDateTime!.day}/${_selectedDateTime!.month} ${_selectedDateTime!.hour}:${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: _selectedDateTime == null ? AppColors.textHint : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _maxPlayers,
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                items: const [4, 6, 8, 10, 14, 22]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n players')))
                    .toList(),
                onChanged: (v) => setState(() => _maxPlayers = v ?? 4),
              ),
            ],
          ),
          const SizedBox(height: 20),
          KickproButton(label: 'Confirm Booking', isLoading: _submitting, onPressed: _submit),
        ],
      ),
    );
  }
}
