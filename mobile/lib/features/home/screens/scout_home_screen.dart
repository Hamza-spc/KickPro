import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/videos/screens/video_feed_screen.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';

class ScoutHomeScreen extends ConsumerStatefulWidget {
  const ScoutHomeScreen({super.key});

  @override
  ConsumerState<ScoutHomeScreen> createState() => _ScoutHomeScreenState();
}

class _ScoutHomeScreenState extends ConsumerState<ScoutHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _index == 0
            ? _ScoutWelcome(onBrowseVideos: () => setState(() => _index = 1))
            : const VideoFeedScreen(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'Videos'),
        ],
      ),
    );
  }
}

class _ScoutWelcome extends ConsumerWidget {
  const _ScoutWelcome({required this.onBrowseVideos});

  final VoidCallback onBrowseVideos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scout Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () => logout(ref),
                icon: const Icon(Icons.logout, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your scout account is active. Full search and AI assistant tools ship in Phase 4.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available now', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('• Browse the player video feed', style: TextStyle(color: AppColors.textSecondary)),
                Text('• View public player profiles (Phase 4 expands search)', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Spacer(),
          KickproButton(
            label: 'Browse Video Feed',
            onPressed: onBrowseVideos,
          ),
        ],
      ),
    );
  }
}
