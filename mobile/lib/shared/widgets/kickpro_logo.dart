import 'package:flutter/material.dart';
import 'package:kickpro/core/constants/app_assets.dart';
import 'package:kickpro/core/theme/app_colors.dart';

class KickproLogo extends StatelessWidget {
  const KickproLogo({super.key, this.height = 48});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.fullWordmarkLogo,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Text(
        'KickPro',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class KickproChatbotLogo extends StatelessWidget {
  const KickproChatbotLogo({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.chatbotLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(Icons.auto_awesome, size: size, color: AppColors.accent),
    );
  }
}

class KickproAppBarLogo extends StatelessWidget implements PreferredSizeWidget {
  const KickproAppBarLogo({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      title: const KickproLogo(height: 32),
      actions: actions,
    );
  }
}
