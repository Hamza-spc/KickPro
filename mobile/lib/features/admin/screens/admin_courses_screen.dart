import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_models.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class AdminCoursesScreen extends ConsumerWidget {
  const AdminCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ref.tr.courses,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => context.push('/admin/create-course'),
                      child: Text(ref.tr.createCourseManually),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push('/admin/generate-course'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const KickproChatbotLogo(size: 18),
                          const SizedBox(width: 6),
                          Text(ref.tr.aiPlusCreate),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(adminCoursesProvider),
              child: coursesAsync.when(
                loading: () => const ListTile(title: ShimmerBox(height: 80, width: double.infinity)),
                error: (e, _) => ListTile(title: Text(apiErrorMessage(e), style: const TextStyle(color: AppColors.error))),
                data: (courses) => ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _CourseCard(course: courses[index]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _pickAndUploadMedia(
  BuildContext context,
  WidgetRef ref,
  int courseId,
  int lessonId,
) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.perm_media_outlined, color: AppColors.accent),
            title: Text(context.tr.chooseImageOrVideo),
            onTap: () => Navigator.pop(ctx, 'media'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.accent),
            title: Text(context.tr.chooseDocument),
            onTap: () => Navigator.pop(ctx, 'document'),
          ),
        ],
      ),
    ),
  );
  if (choice == null || !context.mounted) return;

  String? filePath;
  if (choice == 'media') {
    final picked = await ImagePicker().pickMedia();
    filePath = picked?.path;
  } else {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );
    filePath = picked?.files.single.path;
  }

  if (filePath == null || !context.mounted) return;

  try {
    await ref.read(adminRepositoryProvider).uploadLessonMedia(courseId, lessonId, filePath);
    ref.invalidate(adminCoursesProvider);
    if (context.mounted) showKickproToast(context, ref.tr.lessonMediaUploaded);
  } catch (e) {
    if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
  }
}

class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course});

  final AdminCourseDetail course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          Text('${course.level.label} · ${ref.tr.nLessons(course.lessons.length)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          ...course.lessons.map(
            (lesson) => ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text('${lesson.orderIndex}. ${lesson.title}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              subtitle: Text(
                lesson.mediaUrl == null ? ref.tr.noMediaAttached : '${lesson.mediaType ?? 'MEDIA'} attached',
                style: const TextStyle(color: AppColors.textHint, fontSize: 11),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.upload_file, size: 20, color: AppColors.accent),
                onPressed: () => _pickAndUploadMedia(context, ref, course.id, lesson.id),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () async {
                try {
                  await ref.read(adminRepositoryProvider).deleteCourse(course.id);
                  ref.invalidate(adminCoursesProvider);
                } catch (e) {
                  if (context.mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
                }
              },
              child: Text(ref.tr.deleteCourse, style: const TextStyle(color: AppColors.error)),
            ),
          ),
        ],
      ),
    );
  }
}
