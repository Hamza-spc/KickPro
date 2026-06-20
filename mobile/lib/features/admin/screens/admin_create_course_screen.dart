import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kickpro/core/api/api_error.dart';
import 'package:kickpro/core/l10n/app_translations.dart';
import 'package:kickpro/core/theme/app_colors.dart';
import 'package:kickpro/features/admin/data/admin_repository.dart';
import 'package:kickpro/features/admin/models/admin_course_payload.dart';
import 'package:kickpro/shared/models/drill_models.dart';
import 'package:kickpro/shared/widgets/kickpro_button.dart';
import 'package:kickpro/shared/widgets/kickpro_text_field.dart';
import 'package:kickpro/shared/widgets/kickpro_toast.dart';

class AdminCreateCourseScreen extends ConsumerStatefulWidget {
  const AdminCreateCourseScreen({super.key});

  @override
  ConsumerState<AdminCreateCourseScreen> createState() => _AdminCreateCourseScreenState();
}

class _AdminCreateCourseScreenState extends ConsumerState<AdminCreateCourseScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DrillLevel _level = DrillLevel.beginner;
  bool _saving = false;

  final _lessons = <ManualLessonDraft>[
    ManualLessonDraft(title: '', content: ''),
    ManualLessonDraft(
      title: '',
      content: '',
      quizQuestions: [
        ManualQuizQuestionDraft(
          question: '',
          options: ['', '', '', ''],
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      showKickproToast(context, ref.tr.completeAllFields, isError: true);
      return;
    }

    for (final lesson in _lessons) {
      if (lesson.title.trim().isEmpty || lesson.content.trim().isEmpty) {
        showKickproToast(context, ref.tr.completeAllFields, isError: true);
        return;
      }
    }

    final finalLesson = _lessons.last;
    if (finalLesson.quizQuestions.isEmpty ||
        finalLesson.quizQuestions.any((q) => q.question.trim().isEmpty || q.options.any((o) => o.trim().isEmpty))) {
      showKickproToast(context, ref.tr.completeFinalQuiz, isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).createCourse(
            createCoursePayloadManual(
              title: title,
              description: description,
              level: _level,
              lessons: _lessons,
            ),
          );
      ref.invalidate(adminCoursesProvider);
      if (mounted) {
        showKickproToast(context, ref.tr.coursePublished);
        context.pop();
      }
    } catch (e) {
      if (mounted) showKickproToast(context, apiErrorMessage(e), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
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
                Expanded(
                  child: Text(
                    ref.tr.createCourseManually,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            KickproTextField(controller: _titleController, label: ref.tr.courseTitle),
            const SizedBox(height: 12),
            KickproTextField(
              controller: _descriptionController,
              label: ref.tr.briefDescription,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DrillLevel>(
              initialValue: _level,
              dropdownColor: AppColors.surface,
              decoration: InputDecoration(
                labelText: ref.tr.courseLevel,
                labelStyle: const TextStyle(color: AppColors.textHint),
              ),
              items: DrillLevel.values
                  .map((l) => DropdownMenuItem(value: l, child: Text(ref.tr.drillLevelLabel(l))))
                  .toList(),
              onChanged: (v) => setState(() => _level = v ?? DrillLevel.beginner),
            ),
            const SizedBox(height: 20),
            ...List.generate(_lessons.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _LessonEditor(
                  key: ValueKey('lesson-$index-${_lessons.length}'),
                  index: index,
                  lesson: _lessons[index],
                  isFinal: index == _lessons.length - 1,
                ),
              );
            }),
            KickproButton(
              label: ref.tr.addLesson,
              onPressed: () {
                setState(() {
                  if (_lessons.length >= 2) {
                    _lessons.insert(
                      _lessons.length - 1,
                      ManualLessonDraft(title: '', content: ''),
                    );
                  } else {
                    _lessons.add(ManualLessonDraft(title: '', content: ''));
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            KickproButton(
              label: ref.tr.publishCourse,
              isLoading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonEditor extends StatefulWidget {
  const _LessonEditor({
    super.key,
    required this.index,
    required this.lesson,
    required this.isFinal,
  });

  final int index;
  final ManualLessonDraft lesson;
  final bool isFinal;

  @override
  State<_LessonEditor> createState() => _LessonEditorState();
}

class _LessonEditorState extends State<_LessonEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final List<_QuestionControllers> _questionControllers;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lesson.title);
    _contentController = TextEditingController(text: widget.lesson.content);
    _titleController.addListener(() => widget.lesson.title = _titleController.text);
    _contentController.addListener(() => widget.lesson.content = _contentController.text);
    _questionControllers = widget.lesson.quizQuestions
        .map((q) => _QuestionControllers.fromDraft(q))
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    for (final q in _questionControllers) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    final draft = ManualQuizQuestionDraft(question: '', options: ['', '', '', '']);
    widget.lesson.quizQuestions.add(draft);
    setState(() => _questionControllers.add(_QuestionControllers.fromDraft(draft)));
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
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
          Text(
            tr.lessonN(widget.index + 1),
            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          KickproTextField(controller: _titleController, label: tr.title),
          const SizedBox(height: 8),
          KickproTextField(controller: _contentController, label: tr.lessonContent, maxLines: 4),
          if (widget.isFinal) ...[
            const SizedBox(height: 12),
            Text(tr.finalLessonQuiz, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...List.generate(_questionControllers.length, (qIndex) {
              final qc = _questionControllers[qIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KickproTextField(controller: qc.question, label: tr.questionN(qIndex + 1)),
                    const SizedBox(height: 6),
                    ...List.generate(4, (optionIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Radio<int>(
                              value: optionIndex,
                              groupValue: qc.draft.correctAnswerIndex,
                              onChanged: (v) => setState(() => qc.draft.correctAnswerIndex = v ?? 0),
                              activeColor: AppColors.accent,
                            ),
                            Expanded(
                              child: KickproTextField(
                                controller: qc.options[optionIndex],
                                label: tr.optionN(optionIndex + 1),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
            TextButton(
              onPressed: _addQuestion,
              child: Text(tr.addQuestion, style: const TextStyle(color: AppColors.accent)),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuestionControllers {
  _QuestionControllers({
    required this.draft,
    required this.question,
    required this.options,
  });

  final ManualQuizQuestionDraft draft;
  final TextEditingController question;
  final List<TextEditingController> options;

  factory _QuestionControllers.fromDraft(ManualQuizQuestionDraft draft) {
    final question = TextEditingController(text: draft.question);
    question.addListener(() => draft.question = question.text);
    final options = List.generate(4, (i) {
      final controller = TextEditingController(text: draft.options[i]);
      controller.addListener(() => draft.options[i] = controller.text);
      return controller;
    });
    return _QuestionControllers(draft: draft, question: question, options: options);
  }

  void dispose() {
    question.dispose();
    for (final o in options) {
      o.dispose();
    }
  }
}
