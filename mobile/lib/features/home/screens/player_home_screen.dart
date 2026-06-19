import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/drills/screens/drill_progression_screen.dart';
import 'package:kickpro/features/matches/screens/match_booking_screen.dart';
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

  static const _tabs = [
    VideoFeedScreen(),
    DrillProgressionScreen(),
    MatchBookingScreen(),
    PlayerProfileScreen(),
  ];

  int get _navIndex => _tabIndex < 2 ? _tabIndex : _tabIndex + 1;

  void _onNavSelected(int value) {
    if (value == 2) {
      showCreatePostSheet(context, ref);
      return;
    }
    setState(() => _tabIndex = value > 2 ? value - 1 : value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: _onNavSelected,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Drills',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Post',
          ),
          NavigationDestination(
            icon: Icon(Icons.sports_soccer_outlined),
            selectedIcon: Icon(Icons.sports_soccer),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
