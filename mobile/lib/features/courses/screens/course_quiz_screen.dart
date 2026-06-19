import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/router/navigation_helpers.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/courses/data/course_repository.dart';
import 'package:kickpro/features/profile/screens/player_profile_screen.dart';
import 'package:kickpro/shared/models/course_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';
import 'package:kickpro/shared/widgets/shimmer_box.dart';

class CourseQuizScreen extends ConsumerStatefulWidget {
  const CourseQuizScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final int courseId;
  final int lessonId;

  @override
  ConsumerState<CourseQuizScreen> createState() => _CourseQuizScreenState();
}

class _CourseQuizScreenState extends ConsumerState<CourseQuizScreen> {
  final Map<int, int> _selectedAnswers = {};
  bool _submitting = false;
  QuizResult? _result;

  Future<void> _submit(CourseQuiz quiz) async {
    if (_selectedAnswers.length != quiz.questions.length) {
      showKickproToast(context, 'Please answer all questions', isError: true);
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref.read(courseRepositoryProvider).submitQuiz(
            courseId: widget.courseId,
            lessonId: widget.lessonId,
            answersByQuestionId: _selectedAnswers,
          );
      ref.invalidate(courseDetailProvider(widget.courseId));
      ref.invalidate(coursesListProvider);
      ref.invalidate(myCertificationsProvider);
      ref.invalidate(playerProfileProvider);
      setState(() => _result = result);
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _goBack() {
    if (_result != null) {
      popToCourseDetail(context, widget.courseId);
      return;
    }
    popToCourseDetail(context, widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(
      courseQuizProvider((courseId: widget.courseId, lessonId: widget.lessonId)),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: quizAsync.when(
            loading: () => _QuizHeader(
              title: 'Course Quiz',
              onBack: _goBack,
              body: const Center(child: ShimmerBox(height: 200, width: double.infinity)),
            ),
            error: (error, _) => _QuizHeader(
              title: 'Course Quiz',
              onBack: _goBack,
              body: Center(
                child: Text(apiErrorMessage(error), style: const TextStyle(color: AppColors.error)),
              ),
            ),
            data: (quiz) {
              if (_result != null) {
                return _QuizResultView(
                  result: _result!,
                  onBack: _goBack,
                  onDone: _goBack,
                );
              }
              return _QuizForm(
                quiz: quiz,
                selectedAnswers: _selectedAnswers,
                submitting: _submitting,
                onSelect: (questionId, optionIndex) {
                  setState(() => _selectedAnswers[questionId] = optionIndex);
                },
                onSubmit: () => _submit(quiz),
                onBack: _goBack,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
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

class _QuizForm extends StatelessWidget {
  const _QuizForm({
    required this.quiz,
    required this.selectedAnswers,
    required this.submitting,
    required this.onSelect,
    required this.onSubmit,
    required this.onBack,
  });

  final CourseQuiz quiz;
  final Map<int, int> selectedAnswers;
  final bool submitting;
  final void Function(int questionId, int optionIndex) onSelect;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              const Expanded(
                child: Text(
                  'Course Quiz',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              final question = quiz.questions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _QuestionCard(
                  index: index + 1,
                  question: question,
                  selectedIndex: selectedAnswers[question.id],
                  onSelect: (optionIndex) => onSelect(question.id, optionIndex),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: KickproButton(
            label: 'Submit Quiz',
            isLoading: submitting,
            onPressed: onSubmit,
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int index;
  final QuizQuestion question;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

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
            'Question $index',
            style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            question.question,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (optionIndex) {
            final selected = selectedIndex == optionIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onSelect(optionIndex),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.inputBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: selected ? AppColors.primary : AppColors.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            question.options[optionIndex],
                            style: TextStyle(
                              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QuizResultView extends StatelessWidget {
  const _QuizResultView({
    required this.result,
    required this.onBack,
    required this.onDone,
  });

  final QuizResult result;
  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              ),
              const Expanded(
                child: Text(
                  'Quiz Result',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  passed ? Icons.emoji_events : Icons.replay,
                  size: 72,
                  color: passed ? AppColors.gold : AppColors.textHint,
                ),
                const SizedBox(height: 16),
                Text(
                  passed ? 'Quiz Passed!' : 'Keep Practising',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.scorePercent}% (${result.correctCount}/${result.totalQuestions} correct)',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                if (result.certificationEarned) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D1F00),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Certification Earned',
                          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700),
                        ),
                        if (result.certification != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            result.certification!.courseTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                KickproButton(label: 'Back to Course', onPressed: onDone),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
