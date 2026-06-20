import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/announcements/screens/announcements_screen.dart';
import 'package:kickpro/features/messages/screens/messages_tab.dart';
import 'package:kickpro/features/search/screens/scout_search_screen.dart';

class AgentHomeScreen extends ConsumerStatefulWidget {
  const AgentHomeScreen({super.key});

  @override
  ConsumerState<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends ConsumerState<AgentHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AnnouncementsScreen(key: ValueKey('agent-announcements'), canPost: true),
      const MessagesTab(key: ValueKey('agent-messages')),
      const ScoutSearchScreen(key: ValueKey('agent-search')),
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
            icon: const Icon(Icons.campaign_outlined),
            selectedIcon: const Icon(Icons.campaign),
            label: ref.tr.navTrials,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mail_outline),
            selectedIcon: const Icon(Icons.mail),
            label: ref.tr.navMessages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: ref.tr.navSearch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => logout(ref),
        backgroundColor: AppColors.surface,
        child: const Icon(Icons.logout, color: AppColors.textHint),
      ),
    );
  }
}
