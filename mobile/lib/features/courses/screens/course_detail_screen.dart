import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/router/navigation_helpers.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/courses/models/lesson_view_args.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final int courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      body: SafeArea(
        child: courseAsync.when(
          loading: () => _CourseScaffold(
            title: 'Loading...',
            onBack: () => popCourseFlow(context),
            body: const Center(child: ShimmerBox(height: 240, width: double.infinity)),
          ),
          error: (error, _) => _CourseScaffold(
            title: 'Course',
            onBack: () => popCourseFlow(context),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(apiErrorMessage(error), style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
          data: (course) => _CourseDetailBody(course: course),
        ),
      ),
    );
  }
}

class _CourseScaffold extends StatelessWidget {
  const _CourseScaffold({
    required this.title,
    required this.onBack,
    required this.body,
  });

  final String title;
  final VoidCallback onBack;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _CourseDetailBody extends StatelessWidget {
  const _CourseDetailBody({required this.course});

  final CourseDetail course;

  @override
  Widget build(BuildContext context) {
    final sortedLessons = [...course.lessons]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    final finalLesson = course.finalLesson;
    final hasContent = sortedLessons.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => popCourseFlow(context),
                        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (course.certified)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF052E16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.emoji_events, color: AppColors.success),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'You earned this certification!',
                                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        course.description,
                        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lessons',
                        style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap a lesson to read the full content.',
                        style: TextStyle(color: AppColors.textHint, fontSize: 12),
                      ),
                      if (!hasContent) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border, width: 0.5),
                          ),
                          child: const Text(
                            'This course has no lessons yet. An admin needs to add content before you can take the quiz.',
                            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (hasContent)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final lesson = sortedLessons[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _LessonCard(
                          lesson: lesson,
                          course: course,
                        ),
                      );
                    },
                    childCount: sortedLessons.length,
                  ),
                ),
            ],
          ),
        ),
        if (finalLesson != null && finalLesson.hasQuiz && !course.certified)
          Padding(
            padding: const EdgeInsets.all(16),
            child: KickproButton(
              label: 'Take Final Quiz',
              onPressed: () => context.push('/courses/${course.id}/lessons/${finalLesson.id}/quiz'),
            ),
          ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, required this.course});

  final LessonSummary lesson;
  final CourseDetail course;

  String _preview(String content) {
    if (content.length <= 100) return content;
    return '${content.substring(0, 100).trim()}…';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push(
          '/courses/${course.id}/lessons/${lesson.id}',
          extra: LessonViewArgs(
            lesson: lesson,
            courseId: course.id,
            courseTitle: course.title,
            courseCertified: course.certified,
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${lesson.orderIndex}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lesson.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (lesson.finalLesson)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1F00),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Quiz',
                        style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: AppColors.textHint, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _preview(lesson.content),
                style: const TextStyle(color: AppColors.textSecondary, height: 1.45, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap to read full lesson',
                style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
