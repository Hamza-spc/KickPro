import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/auth/auth_storage.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/matches/data/match_repository.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/match_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

final matchDetailProvider = FutureProvider.autoDispose.family<FootballMatch, int>((ref, matchId) {
  return ref.read(matchRepositoryProvider).getMatch(matchId);
});

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final int matchId;

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  bool _acting = false;

  Future<void> _refresh() async {
    ref.invalidate(matchDetailProvider(widget.matchId));
  }

  Future<void> _join() async {
    setState(() => _acting = true);
    try {
      await ref.read(matchRepositoryProvider).requestToJoin(widget.matchId);
      await _refresh();
      if (mounted) showKickproToast(context, 'Join request sent');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _review(MatchParticipant participant, ParticipantStatus status) async {
    setState(() => _acting = true);
    try {
      await ref.read(matchRepositoryProvider).reviewParticipant(
            matchId: widget.matchId,
            participantId: participant.id,
            status: status,
          );
      await _refresh();
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _acting = true);
    try {
      await ref.read(matchRepositoryProvider).completeMatch(widget.matchId);
      await _refresh();
      if (mounted) showKickproToast(context, 'Match completed — rate your teammates!');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel match?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This cannot be undone.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel match')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _acting = true);
    try {
      await ref.read(matchRepositoryProvider).cancelMatch(widget.matchId);
      await _refresh();
      if (mounted) showKickproToast(context, 'Match cancelled');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchAsync = ref.watch(matchDetailProvider(widget.matchId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Match Details'),
      ),
      body: matchAsync.when(
        loading: () => const Center(child: ShimmerBox(height: 200, width: double.infinity)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.toString(), style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 12),
                KickproButton(label: 'Retry', onPressed: _refresh),
              ],
            ),
          ),
        ),
        data: (match) => FutureBuilder(
          future: Future.wait([
            ref.read(authStorageProvider).getUserId(),
            ref.read(profileRepositoryProvider).getMyProfile(),
          ]),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: ShimmerBox(height: 120, width: double.infinity));
            }
            final userId = snapshot.data![0] as int?;
            final myProfile = snapshot.data![1] as PlayerProfile;
            final isOrganizer = userId != null && userId == match.organizerId;
            MatchParticipant? myParticipant;
            for (final p in match.participants) {
              if (p.playerId == myProfile.id) {
                myParticipant = p;
                break;
              }
            }
            final isApproved = myParticipant?.status == ParticipantStatus.approved;
            final canChat = match.chatRoomId != null && isApproved;
            final canRate = match.isCompleted && isApproved;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _InfoCard(match: match),
                  const SizedBox(height: 16),
                  const Text('Players', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...match.participants.map((p) => _ParticipantTile(
                        participant: p,
                        isOrganizer: isOrganizer,
                        acting: _acting,
                        onApprove: () => _review(p, ParticipantStatus.approved),
                        onReject: () => _review(p, ParticipantStatus.rejected),
                      )),
                  const SizedBox(height: 24),
                  if (!isOrganizer && match.isOpen && myParticipant == null)
                    KickproButton(label: 'Request to Join', isLoading: _acting, onPressed: _join),
                  if (myParticipant?.status == ParticipantStatus.pending)
                    const Text('Your join request is pending approval.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.gold)),
                  if (isOrganizer && !match.isCompleted && match.status != MatchStatus.cancelled) ...[
                    KickproButton(label: 'Mark as Completed', isLoading: _acting, onPressed: _complete),
                    const SizedBox(height: 8),
                    KickproButton(
                      label: 'Cancel Match',
                      variant: KickproButtonVariant.ghost,
                      isLoading: _acting,
                      onPressed: _cancel,
                    ),
                  ],
                  if (canChat) ...[
                    const SizedBox(height: 8),
                    KickproButton(
                      label: 'Open Chat',
                      onPressed: () => context.push('/matches/${match.id}/chat'),
                    ),
                  ],
                  if (canRate) ...[
                    const SizedBox(height: 8),
                    KickproButton(
                      label: 'Rate Players',
                      onPressed: () => context.push('/matches/${match.id}/rate'),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.match});

  final FootballMatch match;

  @override
  Widget build(BuildContext context) {
    final d = match.dateTime;
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
          Text(match.stadiumName,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(match.stadiumLocation, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          _Row(icon: Icons.calendar_today, label: '${d.day}/${d.month}/${d.year} at ${d.hour}:${d.minute.toString().padLeft(2, '0')}'),
          _Row(icon: Icons.groups, label: '${match.approvedCount}/${match.maxPlayers} players confirmed'),
          _Row(icon: Icons.cake_outlined, label: 'Ages ${match.minAge}–${match.maxAge}'),
          _Row(icon: Icons.wc_outlined, label: match.gender.label),
          _Row(icon: Icons.person, label: 'Organizer: ${match.organizerName}'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13))),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.participant,
    required this.isOrganizer,
    required this.acting,
    required this.onApprove,
    required this.onReject,
  });

  final MatchParticipant participant;
  final bool isOrganizer;
  final bool acting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (participant.status) {
      ParticipantStatus.approved => (AppColors.success, 'Approved'),
      ParticipantStatus.pending => (AppColors.gold, 'Pending'),
      ParticipantStatus.rejected => (AppColors.error, 'Rejected'),
    };

    return InkWell(
      onTap: () => openPlayerProfile(context, participant.playerId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              participant.playerName.isNotEmpty ? participant.playerName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(participant.playerName,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12)),
              ],
            ),
          ),
          if (isOrganizer && participant.status == ParticipantStatus.pending) ...[
            IconButton(
              onPressed: acting ? null : onApprove,
              icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
            ),
            IconButton(
              onPressed: acting ? null : onReject,
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
