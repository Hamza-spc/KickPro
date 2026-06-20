import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/drills/data/drill_repository.dart';
import 'package:kickpro/features/drills/screens/drill_progression_screen.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class DrillSubmissionScreen extends ConsumerStatefulWidget {
  const DrillSubmissionScreen({super.key, required this.drill});

  final DrillProgressionItem drill;

  @override
  ConsumerState<DrillSubmissionScreen> createState() => _DrillSubmissionScreenState();
}

class _DrillSubmissionScreenState extends ConsumerState<DrillSubmissionScreen> {
  String? _videoPath;
  bool _submitting = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 2));
    if (video != null) setState(() => _videoPath = video.path);
  }

  Future<void> _submit() async {
    if (_videoPath == null) {
      showKickproToast(context, ref.tr.selectVideoFirst, isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(drillRepositoryProvider).submitDrill(
            drillId: widget.drill.id,
            filePath: _videoPath!,
          );
      ref.invalidate(drillProgressionProvider(widget.drill.level));
      if (!mounted) return;
      showKickproToast(context, ref.tr.submittedForReview);
      context.pop();
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drill = widget.drill;

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
              Text(
                drill.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(drill.description, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.tr.rules, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(drill.rules, style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  children: [
                    Icon(
                      _videoPath == null ? Icons.videocam_outlined : Icons.check_circle,
                      color: _videoPath == null ? AppColors.textHint : AppColors.success,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _videoPath == null ? ref.tr.noVideoSelected : ref.tr.videoReady,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    KickproButton(
                      label: _videoPath == null ? ref.tr.recordPickVideo : ref.tr.changeVideo,
                      variant: KickproButtonVariant.ghost,
                      onPressed: _pickVideo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              KickproButton(
                label: ref.tr.submitForReview,
                isLoading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
