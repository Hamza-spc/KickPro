import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/announcements/data/announcement_repository.dart';
import 'package:kickpro/shared/models/announcement_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key, this.canPost = false});

  final bool canPost;

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  String? _cityFilter;

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsProvider(_cityFilter));

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr.announcements),
        backgroundColor: AppColors.surface,
        actions: [
          if (widget.canPost)
            IconButton(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add, color: AppColors.accent),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(announcementsProvider(_cityFilter)),
        child: announcementsAsync.when(
          loading: () => ListView(
            children: const [
              Padding(padding: EdgeInsets.all(16), child: ShimmerBox(height: 120, width: double.infinity)),
            ],
          ),
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(apiErrorMessage(error), style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Text(ref.tr.noAnnouncementsYet, style: const TextStyle(color: AppColors.textHint)),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) => _AnnouncementCard(
                announcement: items[index],
                canDelete: widget.canPost,
                onDeleted: () => ref.invalidate(announcementsProvider(_cityFilter)),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final cityController = TextEditingController();
    AnnouncementType type = AnnouncementType.trial;
    String? imagePath;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(ref.tr.createAnnouncement, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(controller: titleController, decoration: InputDecoration(labelText: ref.tr.title)),
            const SizedBox(height: 8),
            TextField(controller: contentController, maxLines: 4, decoration: InputDecoration(labelText: ref.tr.description)),
            const SizedBox(height: 8),
            TextField(controller: cityController, decoration: InputDecoration(labelText: ref.tr.city)),
            const SizedBox(height: 8),
            StatefulBuilder(
              builder: (context, setLocal) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (picked == null) return;
                      setLocal(() => imagePath = picked.path);
                    },
                    icon: const Icon(Icons.image_outlined, color: AppColors.accent),
                    label: Text(
                      imagePath == null ? 'Attach image' : 'Image attached',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(imagePath!), height: 140, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            DropdownButtonFormField<AnnouncementType>(
              initialValue: type,
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(labelText: ref.tr.announcementType),
              items: AnnouncementType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(ref.tr.announcementTypeLabel(t))))
                  .toList(),
              onChanged: (v) => type = v ?? AnnouncementType.trial,
            ),
            const SizedBox(height: 16),
            KickproButton(
              label: ref.tr.post,
              onPressed: () async {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                final created = await ref.read(announcementRepositoryProvider).create(
                      CreateAnnouncementRequest(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        type: type,
                        city: cityController.text.trim().isEmpty ? null : cityController.text.trim(),
                      ),
                    );
                if (imagePath != null) {
                  await ref.read(announcementRepositoryProvider).uploadImage(id: created.id, filePath: imagePath!);
                }
                ref.invalidate(announcementsProvider(_cityFilter));
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnnouncementCard extends ConsumerWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.canDelete,
    required this.onDeleted,
  });

  final Announcement announcement;
  final bool canDelete;
  final VoidCallback onDeleted;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(context.tr.delete, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(context.tr.confirmDeleteTrial, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.tr.delete, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(announcementRepositoryProvider).delete(announcement.id);
      onDeleted();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(apiErrorMessage(e)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: announcement.official ? AppColors.gold : AppColors.border,
          width: announcement.official ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (announcement.imageUrl != null && announcement.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                announcement.imageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tr.announcementTypeLabel(announcement.type),
                  style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              if (announcement.official) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: AppColors.gold, size: 16),
                const SizedBox(width: 4),
                Text(tr.official, style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
              const Spacer(),
              if (canDelete && announcement.ownAnnouncement)
                IconButton(
                  onPressed: () => _delete(context, ref),
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                ),
              if (announcement.city != null)
                Text(announcement.city!, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.title,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(announcement.content, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 10),
          Text(
            '${announcement.authorName} · ${_formatDate(announcement.createdAt)}',
            style: const TextStyle(color: AppColors.textHint, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
