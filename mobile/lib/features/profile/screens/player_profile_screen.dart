import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/l10n/locale_provider.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/discovery/widgets/discovery_card.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/widgets/profile_photo_actions.dart';
import 'package:kickpro/features/profile/widgets/profile_share_actions.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/skills_models.dart';
import 'package:kickpro/shared/widgets/credibility_score_card.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:kickpro/shared/widgets/skill_bar.dart';
import 'package:kickpro/features/profile/widgets/profile_timeline_tab.dart';

final playerProfileProvider = FutureProvider.autoDispose<PlayerProfile>((ref) {
  return ref.read(profileRepositoryProvider).getMyProfile();
});

final playerSkillsProvider = FutureProvider.autoDispose<PlayerSkills>((ref) {
  return ref.read(profileRepositoryProvider).getMySkills();
});

class PlayerProfileScreen extends ConsumerStatefulWidget {
  const PlayerProfileScreen({super.key});

  @override
  ConsumerState<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  int _tabIndex = 0;
  bool _uploadingPhoto = false;

  Future<void> _onPhotoTap(PlayerProfile profile) async {
    if (_uploadingPhoto) return;
    await showProfilePhotoOptions(
      context,
      ref,
      profile,
      onUploadingChanged: (uploading) {
        if (mounted) setState(() => _uploadingPhoto = uploading);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileProvider);
    final skillsAsync = ref.watch(playerSkillsProvider);
    final certificationsAsync = ref.watch(myCertificationsProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: ShimmerBox(height: 200, width: double.infinity)),
          error: (e, _) => Center(
            child: Text(e.toString(), style: const TextStyle(color: AppColors.error)),
          ),
          data: (profile) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _ProfileHero(
                profile: profile,
                uploadingPhoto: _uploadingPhoto,
                onPhotoTap: () => _onPhotoTap(profile),
                onEdit: () async {
                  await context.push('/profile/edit');
                  ref.invalidate(playerProfileProvider);
                  ref.invalidate(playerSkillsProvider);
                },
                onLogout: () => logout(ref),
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ReferralCodeCard(),
                      const SizedBox(height: 8),
                      KickproButton(
                        label: ref.tr.mySquads,
                        onPressed: () => context.push('/squads'),
                      ),
                      const SizedBox(height: 8),
                      KickproButton(
                        label: ref.tr.joinSquads,
                        onPressed: () => context.push('/squads/join'),
                      ),
                      const SizedBox(height: 8),
                      KickproButton(
                        label: ref.tr.privateNotes,
                        onPressed: () => context.push('/notes'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _TabButton(label: ref.tr.skills, selected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                      _TabButton(label: ref.tr.certs, selected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                      _TabButton(label: ref.tr.score, selected: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
                      _TabButton(label: ref.tr.timeline, selected: _tabIndex == 3, onTap: () => setState(() => _tabIndex = 3)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: switch (_tabIndex) {
                    0 => skillsAsync.when(
                          loading: () => const ShimmerBox(height: 180, width: double.infinity),
                          error: (e, _) => Text(e.toString()),
                          data: (skills) => _SkillsTab(skills: skills),
                        ),
                    1 => certificationsAsync.when(
                          loading: () => const ShimmerBox(height: 120, width: double.infinity),
                          error: (e, _) => Text(e.toString()),
                          data: (certs) => _CertificationsTab(certifications: certs),
                        ),
                    2 => CredibilityScoreCard(
                          score: profile.credibilityScore,
                          onExplainWithAi: () => context.push('/ai/text/explain-score'),
                        ),
                    _ => ProfileTimelineTab(profileId: profile.id),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends ConsumerWidget {
  const _ProfileHero({
    required this.profile,
    required this.uploadingPhoto,
    required this.onPhotoTap,
    required this.onLogout,
    required this.onEdit,
  });

  final PlayerProfile profile;
  final bool uploadingPhoto;
  final VoidCallback onPhotoTap;
  final VoidCallback onLogout;
  final VoidCallback onEdit;

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                ref.tr.language,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _LangTile(
              flag: '🇬🇧',
              label: ref.tr.english,
              selected: currentLocale.languageCode == 'en',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            _LangTile(
              flag: '🇫🇷',
              label: ref.tr.french,
              selected: currentLocale.languageCode == 'fr',
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                ref.tr.myProfile,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showLanguageSheet(context, ref),
                icon: const Icon(Icons.language, color: AppColors.textHint),
                tooltip: ref.tr.language,
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
                tooltip: ref.tr.editProfileTooltip,
              ),
              IconButton(
                onPressed: () => sharePlayerProfile(context: context, ref: ref, profile: profile),
                icon: const Icon(Icons.share_outlined, color: AppColors.textHint),
                tooltip: ref.tr.shareProfile,
              ),
              IconButton(
                onPressed: () => showProfileQrDialog(context: context, ref: ref, profile: profile),
                icon: const Icon(Icons.qr_code, color: AppColors.textHint),
                tooltip: ref.tr.profileQrTitle,
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: AppColors.textHint),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: uploadingPhoto ? null : onPhotoTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profile.profilePhotoUrl != null
                      ? NetworkImage(profile.profilePhotoUrl!)
                      : null,
                  child: profile.profilePhotoUrl == null
                      ? Text(
                          profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                if (uploadingPhoto)
                  const Positioned.fill(
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                  )
                else
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ref.tr.credibilityN(profile.credibilityScore.round()),
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Badge(label: context.tr.positionLabel(profile.position)),
              _Badge(label: profile.city),
              _Badge(label: context.tr.preferredFootLabel(profile.preferredFoot)),
              if (profile.injured)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    ref.tr.currentlyRecovering,
                    style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textHint,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({required this.skills});
  final PlayerSkills skills;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkillBar(label: context.tr.dribbling, value: skills.dribbling),
          SkillBar(label: context.tr.shooting, value: skills.shooting),
          SkillBar(label: context.tr.passing, value: skills.passing),
          SkillBar(label: context.tr.speed, value: skills.speed),
          SkillBar(label: context.tr.heading, value: skills.heading),
          SkillBar(label: context.tr.stamina, value: skills.stamina),
          if (skills.strengths.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(context.tr.strengths, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
            Text(skills.strengths.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if (skills.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(context.tr.weaknesses, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            Text(skills.weaknesses.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _CertificationsTab extends StatelessWidget {
  const _CertificationsTab({required this.certifications});

  final List<Certification> certifications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KickproButton(
          label: context.tr.browseCourses,
          onPressed: () => context.push('/courses'),
        ),
        const SizedBox(height: 16),
        if (certifications.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Text(
              context.tr.noCertsYet,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          )
        else
          ...certifications.map(
            (cert) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert.courseTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          context.tr.earnedDate(_formatDate(cert.earnedAt)),
                          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _OverviewTab extends ConsumerStatefulWidget {
  const _OverviewTab({required this.profile, required this.onUpdated});

  final PlayerProfile profile;
  final VoidCallback onUpdated;

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab> {
  late bool _injured;
  late TextEditingController _typeCtrl;
  late TextEditingController _bodyCtrl;
  late TextEditingController _severityCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _injured = widget.profile.injured;
    _typeCtrl = TextEditingController(text: widget.profile.injuryType ?? '');
    _bodyCtrl = TextEditingController(text: widget.profile.injuryBodyPart ?? '');
    _severityCtrl = TextEditingController(text: widget.profile.injurySeverity ?? '');
  }

  @override
  void didUpdateWidget(covariant _OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id ||
        oldWidget.profile.injured != widget.profile.injured) {
      _injured = widget.profile.injured;
      _typeCtrl.text = widget.profile.injuryType ?? '';
      _bodyCtrl.text = widget.profile.injuryBodyPart ?? '';
      _severityCtrl.text = widget.profile.injurySeverity ?? '';
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _bodyCtrl.dispose();
    _severityCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveInjury({bool? injured}) async {
    final nextInjured = injured ?? _injured;
    setState(() {
      _injured = nextInjured;
      _saving = true;
    });
    try {
      await ref.read(profileRepositoryProvider).updateInjury(
            injured: nextInjured,
            injuryType: _typeCtrl.text.trim().isEmpty ? null : _typeCtrl.text.trim(),
            injuryBodyPart: _bodyCtrl.text.trim().isEmpty ? null : _bodyCtrl.text.trim(),
            injurySeverity: _severityCtrl.text.trim().isEmpty ? null : _severityCtrl.text.trim(),
          );
      widget.onUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.tr.injuryStatus,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(ref.tr.injuryStatusSubtitle,
                        style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                  ],
                ),
              ),
              if (_saving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                )
              else
                Switch(
                  value: _injured,
                  activeThumbColor: AppColors.error,
                  onChanged: (value) => _saveInjury(injured: value),
                ),
            ],
          ),
          if (_injured) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _typeCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: ref.tr.injuryType,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _saveInjury(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: ref.tr.bodyPart,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _saveInjury(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _severityCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: ref.tr.severity,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _saveInjury(),
            ),
          ],
          const Divider(height: 24, color: AppColors.border),
          _InfoRow(label: context.tr.height, value: '${profile.height} cm'),
          _InfoRow(label: context.tr.weight, value: '${profile.weight} kg'),
          _InfoRow(
            label: context.tr.born,
            value: '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(context.tr.bio, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(profile.bio!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textHint)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
