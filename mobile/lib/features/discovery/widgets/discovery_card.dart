import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/player_profile_navigation.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/discovery/data/discovery_repository.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/shared/models/discovery_models.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:share_plus/share_plus.dart';

class DiscoveryCard extends ConsumerWidget {
  const DiscoveryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(playerProfileProvider);

    return profileAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ShimmerBox(height: 140, width: double.infinity),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (profile) {
        final discoveryAsync = ref.watch(discoveryProvider(profile.city));
        return discoveryAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ShimmerBox(height: 140, width: double.infinity),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (data) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _DiscoveryCardContent(city: profile.city, data: data),
          ),
        );
      },
    );
  }
}

class _DiscoveryCardContent extends ConsumerWidget {
  const _DiscoveryCardContent({required this.city, required this.data});

  final String city;
  final DiscoveryData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2744), Color(0xFF0D2137)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ref.tr.discoveryInCity(city),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                  icon: Icons.people_outline,
                  label: ref.tr.playersNearby,
                  value: '${data.playersNearby}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  icon: Icons.sports_soccer,
                  label: ref.tr.openMatches,
                  value: '${data.openMatches}',
                ),
              ),
            ],
          ),
          if (data.upcomingInCity.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              ref.tr.upcomingMatches,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ...data.upcomingInCity.take(2).map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: GestureDetector(
                  onTap: () => context.push('/matches/${match.id}'),
                  child: Text(
                    '${match.stadiumName} · ${match.dateTime.day}/${match.dateTime.month}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ShortcutChip(
                label: ref.tr.browseClubs,
                icon: Icons.school_outlined,
                onTap: () => context.push('/clubs'),
              ),
              _ShortcutChip(
                label: ref.tr.mySquads,
                icon: Icons.groups_outlined,
                onTap: () => context.push('/squads'),
              ),
              if (data.topPlayers.isNotEmpty)
                _ShortcutChip(
                  label: ref.tr.topPlayers,
                  icon: Icons.emoji_events_outlined,
                  onTap: () => openPlayerProfile(context, data.topPlayers.first.playerId),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.accent),
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
      backgroundColor: const Color(0xFF1E3A5F),
      side: BorderSide.none,
      onPressed: onTap,
    );
  }
}

class ReferralCodeCard extends ConsumerWidget {
  const ReferralCodeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(myReferralProvider);

    return referralAsync.when(
      loading: () => const ShimmerBox(height: 80, width: double.infinity),
      error: (_, _) => const SizedBox.shrink(),
      data: (info) => Container(
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
              ref.tr.referralCode,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    info.code,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: info.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(ref.tr.referralCodeCopied)),
                    );
                  },
                  icon: const Icon(Icons.copy, color: AppColors.textHint),
                  tooltip: ref.tr.copyCode,
                ),
                IconButton(
                  onPressed: () => SharePlus.instance.share(ShareParams(text: ref.tr.referralShareMessage(info.code))),
                  icon: const Icon(Icons.share_outlined, color: AppColors.textHint),
                  tooltip: ref.tr.share,
                ),
              ],
            ),
            Text(
              ref.tr.nReferrals(info.referralCount),
              style: const TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
