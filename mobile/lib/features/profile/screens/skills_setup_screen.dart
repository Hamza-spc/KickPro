import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/skills_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/skill_slider.dart';

class SkillsSetupScreen extends ConsumerStatefulWidget {
  const SkillsSetupScreen({super.key});

  @override
  ConsumerState<SkillsSetupScreen> createState() => _SkillsSetupScreenState();
}

class _SkillsSetupScreenState extends ConsumerState<SkillsSetupScreen> {
  double _dribbling = 5;
  double _shooting = 5;
  double _passing = 5;
  double _speed = 5;
  double _heading = 5;
  double _stamina = 5;
  bool _isLoading = false;

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final skills = PlayerSkills(
        id: 0,
        playerId: 0,
        dribbling: _dribbling.round(),
        shooting: _shooting.round(),
        passing: _passing.round(),
        speed: _speed.round(),
        heading: _heading.round(),
        stamina: _stamina.round(),
        strengths: const [],
        weaknesses: const [],
      );

      await ref.read(profileRepositoryProvider).saveSkills(skills);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.tr.rateSkills,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ref.tr.dragSlider,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  SkillSlider(label: ref.tr.dribbling, value: _dribbling, onChanged: (v) => setState(() => _dribbling = v)),
                  SkillSlider(label: ref.tr.shooting, value: _shooting, onChanged: (v) => setState(() => _shooting = v)),
                  SkillSlider(label: ref.tr.passing, value: _passing, onChanged: (v) => setState(() => _passing = v)),
                  SkillSlider(label: ref.tr.speed, value: _speed, onChanged: (v) => setState(() => _speed = v)),
                  SkillSlider(label: ref.tr.heading, value: _heading, onChanged: (v) => setState(() => _heading = v)),
                  SkillSlider(label: ref.tr.stamina, value: _stamina, onChanged: (v) => setState(() => _stamina = v)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: KickproButton(
                label: ref.tr.saveAndView,
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
