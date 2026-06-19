import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/models/video_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AdminDrillsScreen extends ConsumerStatefulWidget {
  const AdminDrillsScreen({super.key});

  @override
  ConsumerState<AdminDrillsScreen> createState() => _AdminDrillsScreenState();
}

class _AdminDrillsScreenState extends ConsumerState<AdminDrillsScreen> with SingleTickerProviderStateMixin {
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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text('Drills', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          TabBar(
            controller: _tabs,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: const [
              Tab(text: 'Submissions'),
              Tab(text: 'Drill library'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _PendingSubmissionsTab(),
                _DrillLibraryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSubmissionsTab extends ConsumerWidget {
  const _PendingSubmissionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(adminPendingSubmissionsProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminPendingSubmissionsProvider);
        ref.invalidate(adminDashboardProvider);
      },
      child: subsAsync.when(
        loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
        error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
        data: (subs) {
          if (subs.isEmpty) {
            return const ListTile(title: Text('No pending submissions', style: TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: subs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) => _SubmissionCard(submission: subs[index]),
          );
        },
      ),
    );
  }
}

class _SubmissionCard extends ConsumerStatefulWidget {
  const _SubmissionCard({required this.submission});

  final AdminDrillSubmission submission;

  @override
  ConsumerState<_SubmissionCard> createState() => _SubmissionCardState();
}

class _SubmissionCardState extends ConsumerState<_SubmissionCard> {
  final _scoreCtrl = TextEditingController(text: '80');
  bool _acting = false;

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  Future<void> _review(String status) async {
    setState(() => _acting = true);
    try {
      await ref.read(adminRepositoryProvider).reviewSubmission(
            widget.submission.id,
            status: status,
            score: status == 'APPROVED' ? int.tryParse(_scoreCtrl.text.trim()) : null,
          );
      ref.invalidate(adminPendingSubmissionsProvider);
      ref.invalidate(adminDashboardProvider);
      if (mounted) showKickproToast(context, status == 'APPROVED' ? 'Approved' : 'Rejected');
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.submission;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.playerName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          Text(s.drillTitle, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          KickproTextField(controller: _scoreCtrl, label: 'Score (if approving)', keyboardType: TextInputType.number),
          Row(
            children: [
              Expanded(
                child: KickproButton(
                  label: 'Approve',
                  isLoading: _acting,
                  onPressed: _acting ? null : () => _review('APPROVED'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: KickproButton(
                  label: 'Reject',
                  variant: KickproButtonVariant.ghost,
                  onPressed: _acting ? null : () => _review('REJECTED'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrillLibraryTab extends ConsumerWidget {
  const _DrillLibraryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drillsAsync = ref.watch(adminDrillsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminDrillsProvider),
      child: drillsAsync.when(
        loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
        error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
        data: (drills) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openDrillForm(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Create drill'),
              ),
            ),
            ...drills.map(
              (d) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          Text('${d.level.name} · ${d.targetSkill.name}', style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.accent, size: 20),
                      onPressed: () => _openDrillForm(context, ref, drill: d),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                      onPressed: () async {
                        await ref.read(adminRepositoryProvider).deleteDrill(d.id);
                        ref.invalidate(adminDrillsProvider);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDrillForm(BuildContext context, WidgetRef ref, {AdminDrill? drill}) async {
    final titleCtrl = TextEditingController(text: drill?.title ?? '');
    final descCtrl = TextEditingController(text: drill?.description ?? '');
    final rulesCtrl = TextEditingController(text: drill?.rules ?? '');
    final orderCtrl = TextEditingController(text: '${drill?.progressionOrder ?? 1}');
    var level = drill?.level ?? DrillLevel.beginner;
    var skill = drill?.targetSkill ?? TargetSkill.dribbling;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(ctx).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KickproTextField(controller: titleCtrl, label: 'Title'),
              KickproTextField(controller: descCtrl, label: 'Description', maxLines: 2),
              KickproTextField(controller: rulesCtrl, label: 'Rules', maxLines: 2),
              KickproTextField(controller: orderCtrl, label: 'Progression order', keyboardType: TextInputType.number),
              DropdownButtonFormField<DrillLevel>(
                value: level,
                dropdownColor: AppColors.surface,
                items: DrillLevel.values.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                onChanged: (v) => level = v ?? level,
              ),
              DropdownButtonFormField<TargetSkill>(
                value: skill,
                dropdownColor: AppColors.surface,
                items: TargetSkill.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                onChanged: (v) => skill = v ?? skill,
              ),
              const SizedBox(height: 12),
              KickproButton(
                label: drill == null ? 'Create drill' : 'Save drill',
                onPressed: () async {
                  final body = {
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'rules': rulesCtrl.text.trim(),
                    'progressionOrder': int.tryParse(orderCtrl.text.trim()) ?? 1,
                    'level': level.apiValue,
                    'targetSkill': skill.apiValue,
                  };
                  try {
                    if (drill == null) {
                      await ref.read(adminRepositoryProvider).createDrill(body);
                    } else {
                      await ref.read(adminRepositoryProvider).updateDrill(drill.id, body);
                    }
                    ref.invalidate(adminDrillsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) showKickproToast(ctx, apiErrorMessage(e), isError: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
