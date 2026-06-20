import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/messages/screens/messages_tab.dart';
import 'package:kickpro/features/search/screens/scout_bookmarks_screen.dart';
import 'package:kickpro/features/search/screens/scout_search_screen.dart';
import 'package:kickpro/features/videos/screens/video_feed_screen.dart';

class ScoutHomeScreen extends ConsumerStatefulWidget {
  const ScoutHomeScreen({super.key});

  @override
  ConsumerState<ScoutHomeScreen> createState() => _ScoutHomeScreenState();
}

class _ScoutHomeScreenState extends ConsumerState<ScoutHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const ScoutSearchScreen(key: ValueKey('scout-search')),
      const ScoutBookmarksScreen(key: ValueKey('scout-bookmarks')),
      const MessagesTab(key: ValueKey('scout-messages')),
      const VideoFeedScreen(key: ValueKey('scout-feed')),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: tabs,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.3),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: ref.tr.navSearch,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: ref.tr.navBookmarks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outline),
            selectedIcon: const Icon(Icons.mail),
            label: ref.tr.navMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.play_circle_outline),
            selectedIcon: const Icon(Icons.play_circle),
            label: ref.tr.navVideos,
          ),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.small(
              onPressed: () => logout(ref),
              backgroundColor: AppColors.surface,
              child: const Icon(Icons.logout, color: AppColors.textHint),
            )
          : null,
    );
  }
}
