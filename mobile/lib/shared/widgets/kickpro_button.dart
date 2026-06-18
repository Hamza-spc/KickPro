import 'package:flutter/material.dart';
import 'package:kickpro/core/theme/app_colors.dart';

class KickproButton extends StatelessWidget {
  const KickproButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = KickproButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final KickproButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == KickproButtonVariant.primary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.border,
          foregroundColor: isPrimary ? Colors.white : AppColors.textSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: AppColors.primary),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

enum KickproButtonVariant { primary, ghost }
