import 'package:kickpro/shared/models/ai_models.dart';
import 'package:kickpro/shared/models/drill_models.dart';

Map<String, dynamic> createCoursePayloadFromGenerated(GeneratedCourseResponse course) {
  return {
    'title': course.title,
    'description': course.description,
    'level': course.level,
    'lessons': course.lessons.map((lesson) {
      return {
        'title': lesson.title,
        'content': lesson.content,
        'orderIndex': lesson.orderIndex,
        if (lesson.quiz != null)
          'quiz': {
            'questions': lesson.quiz!.questions
                .map(
                  (q) => {
                    'question': q.question,
                    'options': q.options,
                    'correctAnswerIndex': q.correctAnswerIndex,
                  },
                )
                .toList(),
          },
      };
    }).toList(),
  };
}

Map<String, dynamic> createCoursePayloadManual({
  required String title,
  required String description,
  required DrillLevel level,
  required List<ManualLessonDraft> lessons,
}) {
  return {
    'title': title,
    'description': description,
    'level': level.apiValue,
    'lessons': lessons.asMap().entries.map((entry) {
      final index = entry.key;
      final lesson = entry.value;
      final isFinal = index == lessons.length - 1;
      return {
        'title': lesson.title,
        'content': lesson.content,
        'orderIndex': index + 1,
        if (isFinal && lesson.quizQuestions.isNotEmpty)
          'quiz': {
            'questions': lesson.quizQuestions
                .map(
                  (q) => {
                    'question': q.question,
                    'options': q.options,
                    'correctAnswerIndex': q.correctAnswerIndex,
                  },
                )
                .toList(),
          },
      };
    }).toList(),
  };
}

class ManualLessonDraft {
  ManualLessonDraft({
    required this.title,
    required this.content,
    List<ManualQuizQuestionDraft>? quizQuestions,
  }) : quizQuestions = quizQuestions ?? [];

  String title;
  String content;
  List<ManualQuizQuestionDraft> quizQuestions;
}

class ManualQuizQuestionDraft {
  ManualQuizQuestionDraft({
    required this.question,
    required this.options,
    this.correctAnswerIndex = 0,
  });

  String question;
  List<String> options;
  int correctAnswerIndex;
}
