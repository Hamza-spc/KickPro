import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/profile/data/profile_repository.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/shared/models/profile_models.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

Future<void> showProfilePhotoOptions(
  BuildContext context,
  WidgetRef ref,
  PlayerProfile profile, {
  ValueChanged<bool>? onUploadingChanged,
}) async {
  final hasPhoto = profile.profilePhotoUrl != null;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: AppColors.textPrimary),
              title: Text(context.tr.viewProfilePicture, style: const TextStyle(color: AppColors.textPrimary)),
              enabled: hasPhoto,
              onTap: !hasPhoto
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      _viewProfilePhoto(context, profile.profilePhotoUrl!);
                    },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
              title: Text(context.tr.editProfilePicture, style: const TextStyle(color: AppColors.textPrimary)),
              onTap: () async {
                Navigator.pop(sheetContext);
                await pickCropAndUploadProfilePhoto(
                  context,
                  ref,
                  onUploadingChanged: onUploadingChanged,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: Text(context.tr.deleteProfilePicture, style: const TextStyle(color: AppColors.error)),
              enabled: hasPhoto,
              onTap: !hasPhoto
                  ? null
                  : () async {
                      Navigator.pop(sheetContext);
                      await _confirmDeleteProfilePhoto(context, ref);
                    },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<void> pickCropAndUploadProfilePhoto(
  BuildContext context,
  WidgetRef ref, {
  ValueChanged<bool>? onUploadingChanged,
}) async {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 92);
  if (image == null || !context.mounted) return;

  final cropped = await ImageCropper().cropImage(
    sourcePath: image.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 90,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: context.tr.adjustPhoto,
        toolbarColor: AppColors.background,
        toolbarWidgetColor: AppColors.textPrimary,
        activeControlsWidgetColor: AppColors.primary,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: context.tr.adjustPhoto,
        aspectRatioLockEnabled: true,
        resetAspectRatioEnabled: false,
      ),
    ],
  );

  if (cropped == null || !context.mounted) return;

  onUploadingChanged?.call(true);
  try {
    await ref.read(profileRepositoryProvider).uploadPhoto(cropped.path);
    ref.invalidate(playerProfileProvider);
    if (context.mounted) showKickproToast(context, context.tr.profilePhotoUpdated);
  } catch (e) {
    if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
  } finally {
    onUploadingChanged?.call(false);
  }
}

void _viewProfilePhoto(BuildContext context, String photoUrl) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black87,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 280,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  errorBuilder: (_, _, _) => SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(context.tr.couldNotLoadPhoto, style: const TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _confirmDeleteProfilePhoto(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(context.tr.deletePhotoTitle, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(
        context.tr.deletePhotoBody,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(context.tr.cancel)),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(context.tr.delete, style: const TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(profileRepositoryProvider).deletePhoto();
    ref.invalidate(playerProfileProvider);
    if (context.mounted) showKickproToast(context, context.tr.profilePhotoDeleted);
  } catch (e) {
    if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
  }
}
