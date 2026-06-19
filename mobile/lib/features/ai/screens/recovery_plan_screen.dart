import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/ai/data/ai_repository.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class RecoveryPlanScreen extends ConsumerStatefulWidget {
  const RecoveryPlanScreen({super.key});

  @override
  ConsumerState<RecoveryPlanScreen> createState() => _RecoveryPlanScreenState();
}

class _RecoveryPlanScreenState extends ConsumerState<RecoveryPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _injuryController = TextEditingController(text: 'muscle strain');
  final _bodyPartController = TextEditingController(text: 'hamstring');
  final _severityController = TextEditingController(text: 'mild');

  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    _injuryController.dispose();
    _bodyPartController.dispose();
    _severityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final response = await ref.read(aiRepositoryProvider).recoveryPlan(
            RecoveryPlanRequest(
              injuryType: _injuryController.text.trim(),
              bodyPart: _bodyPartController.text.trim(),
              severity: _severityController.text.trim(),
            ),
          );
      setState(() => _result = response.content);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                ),
                const KickproChatbotLogo(size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Recovery Plan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Describe your injury for football-specific recovery guidance.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _Field(
                    controller: _injuryController,
                    label: 'Injury type',
                    hint: 'e.g. muscle strain, sprain',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _bodyPartController,
                    label: 'Body part',
                    hint: 'e.g. hamstring, ankle',
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _severityController,
                    label: 'Severity',
                    hint: 'mild, moderate, or severe',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            KickproButton(
              label: 'Generate Plan',
              isLoading: _loading,
              onPressed: _submit,
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Text(
                  _result!,
                  style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textHint),
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
