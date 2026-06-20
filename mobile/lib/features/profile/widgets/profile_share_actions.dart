import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

String playerProfileDeepLink(int profileId) => 'kickpro://players/$profileId';

Future<void> sharePlayerProfile({
  required BuildContext context,
  required WidgetRef ref,
  required PlayerProfile profile,
}) async {
  final link = playerProfileDeepLink(profile.id);
  await SharePlus.instance.share(
    ShareParams(text: '${profile.fullName} — KickPro\n$link'),
  );
}

Future<void> showProfileQrDialog({
  required BuildContext context,
  required WidgetRef ref,
  required PlayerProfile profile,
}) async {
  final link = playerProfileDeepLink(profile.id);
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(
        ref.tr.profileQrTitle,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: link,
              size: 180,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            link,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(ref.tr.cancel),
        ),
        TextButton(
          onPressed: () async {
            await SharePlus.instance.share(ShareParams(text: link));
          },
          child: Text(ref.tr.share),
        ),
      ],
    ),
  );
}
