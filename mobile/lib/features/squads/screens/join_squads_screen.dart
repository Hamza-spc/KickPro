import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/screens/match_booking_screen.dart';
import 'package:kickpro/features/squads/data/squad_repository.dart';
import 'package:kickpro/shared/models/squad_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class JoinSquadsScreen extends ConsumerStatefulWidget {
  const JoinSquadsScreen({super.key});

  @override
  ConsumerState<JoinSquadsScreen> createState() => _JoinSquadsScreenState();
}

class _JoinSquadsScreenState extends ConsumerState<JoinSquadsScreen> {
  late String _selectedCity;

  @override
  void initState() {
    super.initState();
    _selectedCity = kMatchCities.first;
  }

  @override
  Widget build(BuildContext context) {
    final squadsAsync = ref.watch(discoverSquadsProvider(_selectedCity));

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(discoverSquadsProvider(_selectedCity)),
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
                          ref.tr.joinSquads,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kMatchCities.map((city) {
                      final selected = city == _selectedCity;
                      return ChoiceChip(
                        label: Text(city),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedCity = city),
                        selectedColor: AppColors.primary.withValues(alpha: 0.35),
                        labelStyle: TextStyle(
                          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              squadsAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 120, width: double.infinity),
                  ),
                ),
                error: (error, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        apiErrorMessage(error),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
                data: (squads) {
                  if (squads.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          ref.tr.noSquadsInCity,
                          style: const TextStyle(color: AppColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _DiscoverSquadCard(
                          squad: squads[index],
                          onChanged: () => ref.invalidate(discoverSquadsProvider(_selectedCity)),
                        ),
                      ),
                      childCount: squads.length,
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

class _DiscoverSquadCard extends ConsumerStatefulWidget {
  const _DiscoverSquadCard({required this.squad, required this.onChanged});

  final SquadDiscoverItem squad;
  final VoidCallback onChanged;

  @override
  ConsumerState<_DiscoverSquadCard> createState() => _DiscoverSquadCardState();
}

class _DiscoverSquadCardState extends ConsumerState<_DiscoverSquadCard> {
  bool _loading = false;

  Future<void> _requestJoin() async {
    setState(() => _loading = true);
    try {
      await ref.read(squadRepositoryProvider).requestJoin(widget.squad.id);
      widget.onChanged();
      if (mounted) showKickproToast(context, ref.tr.joinRequestSent);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusLabel(Tr tr) {
    return switch (widget.squad.joinState) {
      'PENDING' => tr.joinRequestPending,
      'MEMBER' => tr.alreadyInSquad,
      'CAPTAIN' => tr.captain,
      _ => '',
    };
  }

  bool get _canRequest => widget.squad.joinState == 'NONE';

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
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
          Text(
            widget.squad.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.squad.city} · ${tr.nMembers(widget.squad.memberCount)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            tr.squadCaptain(widget.squad.captainName),
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (_canRequest)
            KickproButton(
              label: tr.requestToJoin,
              onPressed: _loading ? null : _requestJoin,
              isLoading: _loading,
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _statusLabel(tr),
                style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }
}
