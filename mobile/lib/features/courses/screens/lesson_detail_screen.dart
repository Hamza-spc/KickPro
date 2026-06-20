import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/models/lesson_view_args.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';

class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key, required this.args});

  final LessonViewArgs args;

  @override
  Widget build(BuildContext context) {
    final lesson = args.lesson;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          args.courseTitle,
                          style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                        ),
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.tr.lessonN(lesson.orderIndex),
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (lesson.finalLesson) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D1F00),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.tr.finalQuizLesson,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.content,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.55,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (lesson.finalLesson && lesson.hasQuiz && !args.courseCertified)
              Padding(
                padding: const EdgeInsets.all(16),
                child: KickproButton(
                  label: context.tr.takeFinalQuiz,
                  onPressed: () => context.push(
                    '/courses/${args.courseId}/lessons/${lesson.id}/quiz',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
