import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            statsAsync.when(
              loading: () => const ShimmerBox(height: 120, width: double.infinity),
              error: (e, _) => Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error)),
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Players', value: '${stats.totalPlayers}', icon: Icons.people)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Pending drills', value: '${stats.pendingDrillSubmissions}', icon: Icons.pending_actions)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Active matches', value: '${stats.activeMatches}', icon: Icons.sports_soccer)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Flagged posts', value: '${stats.flaggedPosts}', icon: Icons.flag)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(label: 'Total users', value: '${stats.totalUsers}', icon: Icons.group, fullWidth: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick actions', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _QuickAction(label: 'Add venue', icon: Icons.add_location_alt, onTap: () {}),
                _QuickAction(label: 'Review drills', icon: Icons.check_circle_outline, onTap: () {}),
                InkWell(
                  onTap: () => context.push('/admin/generate-course'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        KickproChatbotLogo(size: 18),
                        SizedBox(width: 8),
                        Text('Generate course', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                _QuickAction(label: 'Moderate posts', icon: Icons.shield_outlined, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, this.fullWidth = false});

  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
