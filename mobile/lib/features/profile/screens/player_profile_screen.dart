import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/skills_models.dart';
import 'package:kickpro/shared/widgets/credibility_ring.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:kickpro/shared/widgets/skill_bar.dart';

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

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      await ref.read(profileRepositoryProvider).uploadPhoto(image.path);
      ref.invalidate(playerProfileProvider);
      if (mounted) showKickproToast(context, 'Profile photo updated');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(playerProfileProvider);
    final skillsAsync = ref.watch(playerSkillsProvider);

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
                onPhotoTap: _pickAndUploadPhoto,
                onLogout: () => logout(ref),
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _TabButton(label: 'Skills', selected: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
                      _TabButton(label: 'Overview', selected: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: _tabIndex == 0
                      ? skillsAsync.when(
                          loading: () => const ShimmerBox(height: 180, width: double.infinity),
                          error: (e, _) => Text(e.toString()),
                          data: (skills) => _SkillsTab(skills: skills),
                        )
                      : _OverviewTab(profile: profile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.profile,
    required this.uploadingPhoto,
    required this.onPhotoTap,
    required this.onLogout,
  });

  final PlayerProfile profile;
  final bool uploadingPhoto;
  final VoidCallback onPhotoTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
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
          const SizedBox(height: 12),
          Text(
            profile.fullName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Badge(label: profile.position.label),
              _Badge(label: profile.city),
              _Badge(label: profile.preferredFoot.name.toUpperCase()),
            ],
          ),
          const SizedBox(height: 20),
          CredibilityRing(score: profile.credibilityScore),
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
          SkillBar(label: 'Dribbling', value: skills.dribbling),
          SkillBar(label: 'Shooting', value: skills.shooting),
          SkillBar(label: 'Passing', value: skills.passing),
          SkillBar(label: 'Speed', value: skills.speed),
          SkillBar(label: 'Heading', value: skills.heading),
          SkillBar(label: 'Stamina', value: skills.stamina),
          if (skills.strengths.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Strengths', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
            Text(skills.strengths.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if (skills.weaknesses.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Weaknesses', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            Text(skills.weaknesses.join(', '), style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.profile});
  final PlayerProfile profile;

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
          _InfoRow(label: 'Height', value: '${profile.height} cm'),
          _InfoRow(label: 'Weight', value: '${profile.weight} kg'),
          _InfoRow(
            label: 'Born',
            value: '${profile.dateOfBirth.day}/${profile.dateOfBirth.month}/${profile.dateOfBirth.year}',
          ),
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Bio', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
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
