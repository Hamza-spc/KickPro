import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/shared/models/user_role.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AdminManageScreen extends ConsumerStatefulWidget {
  const AdminManageScreen({super.key});

  @override
  ConsumerState<AdminManageScreen> createState() => _AdminManageScreenState();
}

class _AdminManageScreenState extends ConsumerState<AdminManageScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(ref.tr.manage, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              Tab(text: ref.tr.users),
              Tab(text: ref.tr.posts),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _UsersTab(),
                _PostsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends ConsumerWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminUsersProvider),
      child: usersAsync.when(
        loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
        error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
        data: (users) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, index) => _UserTile(user: users[index]),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.email, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Text('${user.role.name.toUpperCase()} · ${user.enabled ? ref.tr.active : ref.tr.banned}',
              style: TextStyle(color: user.enabled ? AppColors.success : AppColors.error, fontSize: 12)),
          if (user.role == UserRole.agent && !user.agentVerified)
            Text(ref.tr.agentPendingVerification, style: const TextStyle(color: AppColors.gold, fontSize: 11)),
          Row(
            children: [
              if (user.role != UserRole.admin) ...[
                TextButton(
                  onPressed: () async {
                    try {
                      if (user.enabled) {
                        await ref.read(adminRepositoryProvider).banUser(user.id);
                      } else {
                        await ref.read(adminRepositoryProvider).unbanUser(user.id);
                      }
                      ref.invalidate(adminUsersProvider);
                    } catch (e) {
                      if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                    }
                  },
                  child: Text(user.enabled ? ref.tr.ban : ref.tr.unban, style: TextStyle(color: user.enabled ? AppColors.error : AppColors.success)),
                ),
                TextButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: Text(ref.tr.deleteUser, style: const TextStyle(color: AppColors.textPrimary)),
                        content: Text(ref.tr.confirmDeleteUser, style: const TextStyle(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(ref.tr.cancel)),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(ref.tr.deleteUser, style: const TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !context.mounted) return;
                    try {
                      await ref.read(adminRepositoryProvider).deleteUser(user.id);
                      ref.invalidate(adminUsersProvider);
                      if (context.mounted) showKickproToast(context, ref.tr.userDeleted);
                    } catch (e) {
                      if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                    }
                  },
                  child: Text(ref.tr.deleteUser, style: const TextStyle(color: AppColors.error)),
                ),
              ],
              if (user.role == UserRole.agent && !user.agentVerified)
                TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(adminRepositoryProvider).verifyAgent(user.id);
                      ref.invalidate(adminUsersProvider);
                      if (context.mounted) showKickproToast(context, ref.tr.agentVerified);
                    } catch (e) {
                      if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                    }
                  },
                  child: Text(ref.tr.verifyAgent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostsTab extends ConsumerStatefulWidget {
  const _PostsTab();

  @override
  ConsumerState<_PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends ConsumerState<_PostsTab> {
  bool _flaggedOnly = false;

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(adminPostsProvider(_flaggedOnly));
    return Column(
      children: [
        SwitchListTile(
          title: Text(ref.tr.flaggedOnly, style: const TextStyle(color: AppColors.textPrimary)),
          value: _flaggedOnly,
          onChanged: (v) => setState(() => _flaggedOnly = v),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminPostsProvider(_flaggedOnly));
              ref.invalidate(adminDashboardProvider);
            },
            child: postsAsync.when(
              loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
              error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
              data: (posts) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final post = posts[index];
                  if (post.hidden) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: post.flagged ? AppColors.error : AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        Text('${post.playerName} · ${post.postType}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () async {
                                await ref.read(adminRepositoryProvider).flagPost(post.id, flagged: !post.flagged);
                                ref.invalidate(adminPostsProvider(_flaggedOnly));
                                ref.invalidate(adminDashboardProvider);
                              },
                              child: Text(post.flagged ? ref.tr.unflag : ref.tr.flag),
                            ),
                            TextButton(
                              onPressed: () async {
                                await ref.read(adminRepositoryProvider).removePost(post.id);
                                ref.invalidate(adminPostsProvider(_flaggedOnly));
                                if (context.mounted) showKickproToast(context, ref.tr.postRemoved);
                              },
                              child: Text(ref.tr.remove, style: const TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
