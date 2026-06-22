import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/drills/screens/drill_progression_screen.dart';
import 'package:kickpro/features/matches/screens/match_booking_screen.dart';
import 'package:kickpro/features/messages/screens/messages_tab.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/features/videos/screens/create_post_sheet.dart';
import 'package:kickpro/features/videos/screens/video_feed_screen.dart';

class PlayerHomeScreen extends ConsumerStatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  ConsumerState<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends ConsumerState<PlayerHomeScreen> {
  int _tabIndex = 0;

  int get _navIndex {
    if (_tabIndex < 2) return _tabIndex;
    if (_tabIndex == 2) return 3;
    if (_tabIndex == 3) return 4;
    return 5;
  }

  void _onNavSelected(int value) {
    if (value == 2) {
      showCreatePostSheet(context, ref);
      return;
    }
    setState(() {
      _tabIndex = switch (value) {
        0 => 0,
        1 => 1,
        3 => 2,
        4 => 3,
        5 => 4,
        _ => _tabIndex,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const VideoFeedScreen(key: ValueKey('feed')),
      const DrillProgressionScreen(key: ValueKey('drills')),
      const MatchBookingScreen(key: ValueKey('matches')),
      const MessagesTab(key: ValueKey('player-messages')),
      const PlayerProfileScreen(key: ValueKey('profile')),
    ];

    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavSelected,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline),
            selectedIcon: const Icon(Icons.play_circle),
            label: ref.tr.navFeed,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: ref.tr.navDrills,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: ref.tr.navPost,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_soccer_outlined),
            selectedIcon: const Icon(Icons.sports_soccer),
            label: ref.tr.navMatches,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inbox_outlined),
            selectedIcon: const Icon(Icons.inbox),
            label: ref.tr.navMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: ref.tr.navProfile,
          ),
        ],
      ),
    );
  }
}
