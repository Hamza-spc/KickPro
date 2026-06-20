import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_course_payload.dart';
import 'package:kickpro/features/ai/data/ai_repository.dart';
import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_logo.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class AdminGenerateCourseScreen extends ConsumerStatefulWidget {
  const AdminGenerateCourseScreen({super.key});

  @override
  ConsumerState<AdminGenerateCourseScreen> createState() => _AdminGenerateCourseScreenState();
}

class _AdminGenerateCourseScreenState extends ConsumerState<AdminGenerateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _loading = false;
  bool _publishing = false;
  GeneratedCourseResponse? _result;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final response = await ref.read(aiRepositoryProvider).generateCourse(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
          );
      setState(() => _result = response);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _publish() async {
    final course = _result;
    if (course == null) return;

    setState(() => _publishing = true);
    try {
      await ref.read(adminRepositoryProvider).createCourse(
            createCoursePayloadFromGenerated(course),
          );
      ref.invalidate(adminCoursesProvider);
      if (mounted) {
        showKickproToast(context, ref.tr.coursePublished);
        context.pop();
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _publishing = false);
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
                Expanded(
                  child: Text(
                    ref.tr.generateCourseTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ref.tr.generateCourseSubtitle,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? ref.tr.titleRequired : null,
                    decoration: _decoration(ref.tr.courseTitle),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    validator: (v) => v == null || v.trim().isEmpty ? ref.tr.descriptionRequired : null,
                    decoration: _decoration(ref.tr.briefDescription),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            KickproButton(
              label: ref.tr.generateWithAi,
              isLoading: _loading,
              onPressed: _submit,
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _CoursePreview(course: _result!),
              const SizedBox(height: 16),
              KickproButton(
                label: ref.tr.publishCourse,
                isLoading: _publishing,
                onPressed: _publishing ? null : _publish,
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textHint),
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
    );
  }
}

class _CoursePreview extends StatelessWidget {
  const _CoursePreview({required this.course});

  final GeneratedCourseResponse course;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(course.level, style: const TextStyle(color: AppColors.accent)),
          const SizedBox(height: 8),
          Text(course.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          ...course.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${context.tr.lessonN(lesson.orderIndex)}: ${lesson.title}',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
                  ),
                  if (lesson.quiz != null)
                    Text(
                      context.tr.nQuizQuestions(lesson.quiz!.questions.length),
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
