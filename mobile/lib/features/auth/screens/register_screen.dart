import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/router/app_router.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/auth/data/auth_repository.dart';
import 'package:kickpro/shared/models/user_role.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  UserRole _role = UserRole.player;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).register(
            email: _emailController.text,
            password: _passwordController.text,
            role: _role,
            referralCode: _referralController.text,
          );
      if (!mounted) return;
      if (_role == UserRole.player) {
        await navigateAfterAuth(ref);
      } else if (_role == UserRole.agent) {
        showKickproToast(context, ref.tr.agentAccountCreated);
        await navigateAfterAuth(ref);
      } else {
        showKickproToast(context, ref.tr.scoutAccountCreated);
        await navigateAfterAuth(ref);
      }
    } catch (e) {
      if (mounted) {
        showKickproToast(context, authErrorMessage(e), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Center(child: KickproLogo(height: 40)),
              const SizedBox(height: 24),
              Text(
                ref.tr.createAccount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ref.tr.joinKickpro,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Text(ref.tr.iAmA, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RoleChip(
                    label: ref.tr.player,
                    selected: _role == UserRole.player,
                    onTap: () => setState(() => _role = UserRole.player),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    label: ref.tr.scout,
                    selected: _role == UserRole.scout,
                    onTap: () => setState(() => _role = UserRole.scout),
                  ),
                  const SizedBox(width: 8),
                  _RoleChip(
                    label: ref.tr.agent,
                    selected: _role == UserRole.agent,
                    onTap: () => setState(() => _role = UserRole.agent),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              KickproTextField(
                controller: _emailController,
                label: ref.tr.email,
                hint: ref.tr.emailHint,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              KickproTextField(
                controller: _passwordController,
                label: ref.tr.password,
                hint: ref.tr.passwordMinHint,
                obscureText: _obscurePassword,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textHint,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              if (_role == UserRole.player) ...[
                const SizedBox(height: 16),
                KickproTextField(
                  controller: _referralController,
                  label: ref.tr.referralCodeOptional,
                  hint: ref.tr.referralCodeHint,
                ),
              ],
              const SizedBox(height: 24),
              KickproButton(
                label: ref.tr.createAccount,
                isLoading: _isLoading,
                onPressed: _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
