import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');

  DateTime? _dateOfBirth;
  PlayerPosition _position = PlayerPosition.striker;
  PreferredFoot _foot = PreferredFoot.right;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(now.year - 40),
      lastDate: DateTime(now.year - 14),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _save() async {
    if (_dateOfBirth == null) {
      showKickproToast(context, 'Please select your date of birth', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = PlayerProfile(
        id: 0,
        userId: 0,
        fullName: _nameController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        city: _cityController.text.trim(),
        position: _position,
        preferredFoot: _foot,
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        height: int.parse(_heightController.text),
        weight: int.parse(_weightController.text),
        profilePhotoUrl: null,
        credibilityScore: 0,
      );

      await ref.read(profileRepositoryProvider).saveProfile(profile);
      if (!mounted) return;
      context.go('/skills-setup');
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobLabel = _dateOfBirth == null
        ? 'Select date'
        : DateFormat('dd MMM yyyy').format(_dateOfBirth!);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Build your profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell scouts who you are on the pitch',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              KickproTextField(controller: _nameController, label: 'Full name', hint: 'Youssef Benali'),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: KickproTextField(
                    controller: TextEditingController(text: dobLabel),
                    label: 'Date of birth',
                    hint: 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              KickproTextField(controller: _cityController, label: 'City', hint: 'Casablanca'),
              const SizedBox(height: 16),
              _DropdownField<PlayerPosition>(
                label: 'Position',
                value: _position,
                items: PlayerPosition.values,
                labelBuilder: (p) => p.label,
                onChanged: (v) => setState(() => _position = v),
              ),
              const SizedBox(height: 16),
              _DropdownField<PreferredFoot>(
                label: 'Preferred foot',
                value: _foot,
                items: PreferredFoot.values,
                labelBuilder: (f) => f.name[0].toUpperCase() + f.name.substring(1),
                onChanged: (v) => setState(() => _foot = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: KickproTextField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: KickproTextField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              KickproTextField(
                controller: _bioController,
                label: 'Bio (optional)',
                hint: 'Fast winger from Casablanca...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              KickproButton(label: 'Continue to Skills', isLoading: _isLoading, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 0.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        labelBuilder(item),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
