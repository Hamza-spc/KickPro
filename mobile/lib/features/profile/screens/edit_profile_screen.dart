import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/features/profile/widgets/profile_photo_actions.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/models/skills_models.dart';
import 'package:kickpro/shared/widgets/kickpro_avatar.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:kickpro/shared/widgets/skill_slider.dart';

const _profileCities = [
  'Rabat',
  'Casablanca',
  'Marrakech',
  'Fes',
  'Tanger',
  'Agadir',
  'Oujda',
  'Meknes',
];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _city;
  PlayerPosition _position = PlayerPosition.striker;
  PreferredFoot _foot = PreferredFoot.right;

  double _dribbling = 5;
  double _shooting = 5;
  double _passing = 5;
  double _speed = 5;
  double _heading = 5;
  double _stamina = 5;

  bool _loading = false;
  bool _uploadingPhoto = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _prefill(PlayerProfile profile, PlayerSkills skills) {
    if (_initialized) return;
    _nameController.text = profile.fullName;
    _bioController.text = profile.bio ?? '';
    _heightController.text = '${profile.height}';
    _weightController.text = '${profile.weight}';
    _dateOfBirth = profile.dateOfBirth;
    _city = _profileCities.contains(profile.city) ? profile.city : _profileCities.first;
    _position = profile.position;
    _foot = profile.preferredFoot;
    _dribbling = skills.dribbling.toDouble();
    _shooting = skills.shooting.toDouble();
    _passing = skills.passing.toDouble();
    _speed = skills.speed.toDouble();
    _heading = skills.heading.toDouble();
    _stamina = skills.stamina.toDouble();
    _initialized = true;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18),
      firstDate: DateTime(now.year - 40),
      lastDate: DateTime(now.year - 14),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save(PlayerProfile existing) async {
    if (_dateOfBirth == null || _city == null) {
      showKickproToast(context, ref.tr.completeAllFields, isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final updatedProfile = PlayerProfile(
        id: existing.id,
        userId: existing.userId,
        fullName: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        city: _city!,
        position: _position,
        preferredFoot: _foot,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        height: int.parse(_heightController.text),
        weight: int.parse(_weightController.text),
        profilePhotoUrl: existing.profilePhotoUrl,
        credibilityScore: existing.credibilityScore,
      );

      await ref.read(profileRepositoryProvider).saveProfile(updatedProfile);
      await ref.read(profileRepositoryProvider).saveSkills(
            PlayerSkills(
              id: 0,
              playerId: existing.id,
              dribbling: _dribbling.round(),
              shooting: _shooting.round(),
              passing: _passing.round(),
              speed: _speed.round(),
              heading: _heading.round(),
              stamina: _stamina.round(),
              strengths: const [],
              weaknesses: const [],
            ),
          );

      ref.invalidate(playerProfileProvider);
      ref.invalidate(playerSkillsProvider);

      if (mounted) {
        showKickproToast(context, ref.tr.profileUpdated);
        context.pop();
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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
          error: (e, _) => Center(child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
          data: (profile) => skillsAsync.when(
            loading: () => const Center(child: ShimmerBox(height: 200, width: double.infinity)),
            error: (e, _) => Center(child: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
            data: (skills) {
              _prefill(profile, skills);
              final dobLabel = _dateOfBirth == null
                  ? ref.tr.selectDate
                  : DateFormat('dd MMM yyyy').format(_dateOfBirth!);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                        ),
                        Expanded(
                          child: Text(
                            ref.tr.editProfile,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _uploadingPhoto
                                ? null
                                : () => pickCropAndUploadProfilePhoto(
                                      context,
                                      ref,
                                      onUploadingChanged: (v) => setState(() => _uploadingPhoto = v),
                                    ),
                            child: Stack(
                              children: [
                                KickproAvatar(
                                  radius: 40,
                                  photoUrl: profile.profilePhotoUrl,
                                  name: profile.fullName,
                                  fallbackFontSize: 24,
                                ),
                                if (_uploadingPhoto)
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
                        ),
                        const SizedBox(height: 24),
                        KickproTextField(controller: _nameController, label: ref.tr.fullName),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _pickDate,
                          child: AbsorbPointer(
                            child: KickproTextField(
                              controller: TextEditingController(text: dobLabel),
                              label: ref.tr.dateOfBirth,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _city,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(labelText: ref.tr.city),
                          items: _profileCities
                              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                              .toList(),
                          onChanged: (v) => setState(() => _city = v),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PlayerPosition>(
                          value: _position,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(labelText: ref.tr.position),
                          items: PlayerPosition.values
                              .map((p) => DropdownMenuItem(value: p, child: Text(ref.tr.positionLabel(p))))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _position = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PreferredFoot>(
                          value: _foot,
                          dropdownColor: AppColors.surface,
                          decoration: InputDecoration(labelText: ref.tr.preferredFoot),
                          items: PreferredFoot.values
                              .map((f) => DropdownMenuItem(
                                    value: f,
                                    child: Text(ref.tr.preferredFootLabel(f)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _foot = v);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: KickproTextField(
                                controller: _heightController,
                                label: ref.tr.heightCm,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: KickproTextField(
                                controller: _weightController,
                                label: ref.tr.weightKg,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        KickproTextField(
                          controller: _bioController,
                          label: ref.tr.bio,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          ref.tr.skillRatings,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SkillSlider(label: ref.tr.dribbling, value: _dribbling, onChanged: (v) => setState(() => _dribbling = v)),
                        SkillSlider(label: ref.tr.shooting, value: _shooting, onChanged: (v) => setState(() => _shooting = v)),
                        SkillSlider(label: ref.tr.passing, value: _passing, onChanged: (v) => setState(() => _passing = v)),
                        SkillSlider(label: ref.tr.speed, value: _speed, onChanged: (v) => setState(() => _speed = v)),
                        SkillSlider(label: ref.tr.heading, value: _heading, onChanged: (v) => setState(() => _heading = v)),
                        SkillSlider(label: ref.tr.stamina, value: _stamina, onChanged: (v) => setState(() => _stamina = v)),
                        const SizedBox(height: 24),
                        KickproButton(
                          label: ref.tr.saveChanges,
                          isLoading: _loading,
                          onPressed: () => _save(profile),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
