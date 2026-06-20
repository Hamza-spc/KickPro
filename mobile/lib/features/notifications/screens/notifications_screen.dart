import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/notifications/data/notification_repository.dart';
import 'package:kickpro/shared/widgets/kickpro_empty_state.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr.notifications),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: Text(ref.tr.markAllRead, style: const TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
          ref.invalidate(unreadCountProvider);
        },
        child: notificationsAsync.when(
          loading: () => ListView(children: const [Padding(padding: EdgeInsets.all(16), child: ShimmerBox(height: 80, width: double.infinity))]),
          error: (e, _) => ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text(apiErrorMessage(e)))]),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: [
                  KickproEmptyState(
                    icon: Icons.notifications_none_outlined,
                    message: ref.tr.noNotificationsYet,
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final n = items[index];
                return InkWell(
                  onTap: () {
                    if (n.type == 'DIRECT_MESSAGE' && n.referenceId != null) {
                      context.push('/messages/chat/${n.referenceId}');
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: n.read ? AppColors.surface : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(n.body, style: const TextStyle(color: AppColors.textSecondary, height: 1.3)),
                    ],
                  ),
                ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
