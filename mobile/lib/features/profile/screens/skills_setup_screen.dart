import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate your skills',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Drag each slider from 1 to 10 stars',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  SkillSlider(label: 'Dribbling', value: _dribbling, onChanged: (v) => setState(() => _dribbling = v)),
                  SkillSlider(label: 'Shooting', value: _shooting, onChanged: (v) => setState(() => _shooting = v)),
                  SkillSlider(label: 'Passing', value: _passing, onChanged: (v) => setState(() => _passing = v)),
                  SkillSlider(label: 'Speed', value: _speed, onChanged: (v) => setState(() => _speed = v)),
                  SkillSlider(label: 'Heading', value: _heading, onChanged: (v) => setState(() => _heading = v)),
                  SkillSlider(label: 'Stamina', value: _stamina, onChanged: (v) => setState(() => _stamina = v)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: KickproButton(
                label: 'Save & View Profile',
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
