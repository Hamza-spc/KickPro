import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/videos/data/post_repository.dart';
import 'package:kickpro/shared/models/post_models.dart';
import 'package:kickpro/shared/models/video_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

Future<void> showCreatePostSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const _CreatePostSheet(),
  );
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet();

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _captionController = TextEditingController();
  PostType _postType = PostType.text;
  TargetSkill? _skillTag;
  bool _loading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      showKickproToast(context, context.tr.writeSomethingFirst, isError: true);
      return;
    }

    String? filePath;
    if (_postType == PostType.video) {
      final picked = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (picked == null) return;
      filePath = picked.path;
    } else if (_postType == PostType.image) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      filePath = picked.path;
    }

    setState(() => _loading = true);
    try {
      await ref.read(postRepositoryProvider).createPost(
            title: caption,
            postType: _postType,
            skillTag: _skillTag,
            filePath: filePath,
          );
      ref.invalidate(postFeedProvider);
      if (mounted) {
        Navigator.pop(context);
        showKickproToast(context, context.tr.postShared);
      }
    } catch (e) {
      if (mounted) showKickproToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr.createPost,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.textHint),
              ),
            ],
          ),
          SegmentedButton<PostType>(
            segments: [
              ButtonSegment(value: PostType.text, label: Text(context.tr.text), icon: const Icon(Icons.text_fields)),
              ButtonSegment(value: PostType.image, label: Text(context.tr.photo), icon: const Icon(Icons.image)),
              ButtonSegment(value: PostType.video, label: Text(context.tr.video), icon: const Icon(Icons.videocam)),
            ],
            selected: {_postType},
            onSelectionChanged: (value) => setState(() => _postType = value.first),
          ),
          const SizedBox(height: 16),
          KickproTextField(
            controller: _captionController,
            label: context.tr.caption,
            hint: _postType == PostType.text
                ? context.tr.captionHintText
                : context.tr.captionHintMedia,
            maxLines: 4,
          ),
          if (_postType != PostType.text) ...[
            const SizedBox(height: 12),
            Text(context.tr.skillTagOptional, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TargetSkill.values.map((skill) {
                final selected = _skillTag == skill;
                return ChoiceChip(
                  label: Text(skill.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _skillTag = selected ? null : skill),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary),
                  backgroundColor: AppColors.background,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          KickproButton(
            label: _postType == PostType.text
                ? context.tr.post
                : _postType == PostType.image
                    ? context.tr.pickPhotoPost
                    : context.tr.pickVideoPost,
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
