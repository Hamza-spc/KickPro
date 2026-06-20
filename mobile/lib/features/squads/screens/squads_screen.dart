import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/squads/data/squad_repository.dart';
import 'package:kickpro/shared/models/squad_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class SquadsScreen extends ConsumerWidget {
  const SquadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final squadsAsync = ref.watch(mySquadsProvider);
    final requestsAsync = ref.watch(incomingJoinRequestsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(mySquadsProvider);
            ref.invalidate(incomingJoinRequestsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          ref.tr.mySquads,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/squads/join'),
                        child: Text(ref.tr.joinSquads, style: const TextStyle(color: AppColors.accent)),
                      ),
                    ],
                  ),
                ),
              ),
              requestsAsync.when(
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                data: (requests) {
                  if (requests.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.tr.incomingJoinRequests,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...requests.map(
                            (request) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _JoinRequestCard(request: request),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                          ref.tr.noSquadsYet,
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
                        child: _SquadCard(squad: squads[index]),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSquadSheet(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.group_add),
        label: Text(ref.tr.createSquad),
      ),
    );
  }

  void _showCreateSquadSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _CreateSquadSheet(
        onCreated: () {
          ref.invalidate(mySquadsProvider);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _JoinRequestCard extends ConsumerStatefulWidget {
  const _JoinRequestCard({required this.request});

  final SquadJoinRequestItem request;

  @override
  ConsumerState<_JoinRequestCard> createState() => _JoinRequestCardState();
}

class _JoinRequestCardState extends ConsumerState<_JoinRequestCard> {
  bool _acting = false;

  Future<void> _approve() async {
    setState(() => _acting = true);
    try {
      await ref.read(squadRepositoryProvider).approveJoinRequest(widget.request.id);
      ref.invalidate(incomingJoinRequestsProvider);
      ref.invalidate(mySquadsProvider);
      if (mounted) showKickproToast(context, ref.tr.approved);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _acting = true);
    try {
      await ref.read(squadRepositoryProvider).rejectJoinRequest(widget.request.id);
      ref.invalidate(incomingJoinRequestsProvider);
      if (mounted) showKickproToast(context, ref.tr.rejected);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.request.playerName,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.request.squadName} · ${widget.request.squadCity}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: KickproButton(
                  label: ref.tr.approve,
                  onPressed: _acting ? null : _approve,
                  isLoading: _acting,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KickproButton(
                  label: ref.tr.reject,
                  onPressed: _acting ? null : _reject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SquadCard extends StatelessWidget {
  const _SquadCard({required this.squad});

  final SquadSummary squad;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(
                  squad.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (squad.ownSquad)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.tr.captain,
                    style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${squad.city} · ${context.tr.nMembers(squad.memberCount)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr.squadCaptain(squad.captainName),
            style: const TextStyle(color: AppColors.textHint, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CreateSquadSheet extends ConsumerStatefulWidget {
  const _CreateSquadSheet({required this.onCreated});

  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateSquadSheet> createState() => _CreateSquadSheetState();
}

class _CreateSquadSheetState extends ConsumerState<_CreateSquadSheet> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    if (name.isEmpty || city.isEmpty) {
      showKickproToast(context, ref.tr.completeAllFields, isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(squadRepositoryProvider).createSquad(name: name, city: city);
      if (mounted) {
        showKickproToast(context, ref.tr.squadCreated);
        widget.onCreated();
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ref.tr.createSquad,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          KickproTextField(
            controller: _nameController,
            label: ref.tr.squadName,
            hint: ref.tr.squadNameHint,
          ),
          const SizedBox(height: 12),
          KickproTextField(
            controller: _cityController,
            label: ref.tr.city,
            hint: ref.tr.cityHint,
          ),
          const SizedBox(height: 20),
          KickproButton(
            label: ref.tr.createSquad,
            onPressed: _loading ? null : _submit,
            isLoading: _loading,
          ),
        ],
      ),
    );
  }
}
