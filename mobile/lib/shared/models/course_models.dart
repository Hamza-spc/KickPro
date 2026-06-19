import 'package:kickpro/shared/models/drill_models.dart';

class CourseSummary {
  final int id;
  final String title;
  final String description;
  final DrillLevel level;
  final int lessonCount;
  final bool certified;

  const CourseSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.lessonCount,
    required this.certified,
  });

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      level: DrillLevelApi.fromApi(json['level'] as String),
      lessonCount: (json['lessonCount'] as num).toInt(),
      certified: json['certified'] as bool? ?? false,
    );
  }
}

class CourseDetail {
  final int id;
  final String title;
  final String description;
  final DrillLevel level;
  final bool certified;
  final List<LessonSummary> lessons;

  const CourseDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.certified,
    required this.lessons,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      level: DrillLevelApi.fromApi(json['level'] as String),
      certified: json['certified'] as bool? ?? false,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((item) => LessonSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  LessonSummary? get finalLesson {
    for (final lesson in lessons) {
      if (lesson.finalLesson) return lesson;
    }
    return lessons.isEmpty ? null : lessons.last;
  }
}

class LessonSummary {
  final int id;
  final String title;
  final String content;
  final int orderIndex;
  final bool hasQuiz;
  final bool finalLesson;

  const LessonSummary({
    required this.id,
    required this.title,
    required this.content,
    required this.orderIndex,
    required this.hasQuiz,
    required this.finalLesson,
  });

  factory LessonSummary.fromJson(Map<String, dynamic> json) {
    return LessonSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      orderIndex: (json['orderIndex'] as num).toInt(),
      hasQuiz: json['hasQuiz'] as bool? ?? false,
      finalLesson: json['finalLesson'] as bool? ?? false,
    );
  }
}

class CourseQuiz {
  final int id;
  final int lessonId;
  final int courseId;
  final List<QuizQuestion> questions;

  const CourseQuiz({
    required this.id,
    required this.lessonId,
    required this.courseId,
    required this.questions,
  });

  factory CourseQuiz.fromJson(Map<String, dynamic> json) {
    return CourseQuiz(
      id: (json['id'] as num).toInt(),
      lessonId: (json['lessonId'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: (json['id'] as num).toInt(),
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
    );
  }
}

class QuizResult {
  final bool passed;
  final int scorePercent;
  final int correctCount;
  final int totalQuestions;
  final bool certificationEarned;
  final Certification? certification;

  const QuizResult({
    required this.passed,
    required this.scorePercent,
    required this.correctCount,
    required this.totalQuestions,
    required this.certificationEarned,
    this.certification,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      passed: json['passed'] as bool? ?? false,
      scorePercent: (json['scorePercent'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      certificationEarned: json['certificationEarned'] as bool? ?? false,
      certification: json['certification'] == null
          ? null
          : Certification.fromJson(json['certification'] as Map<String, dynamic>),
    );
  }
}

class Certification {
  final int id;
  final int courseId;
  final String courseTitle;
  final String badgeUrl;
  final DateTime earnedAt;

  const Certification({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.badgeUrl,
    required this.earnedAt,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      id: (json['id'] as num).toInt(),
      courseId: (json['courseId'] as num).toInt(),
      courseTitle: json['courseTitle'] as String,
      badgeUrl: json['badgeUrl'] as String,
      earnedAt: DateTime.parse(json['earnedAt'] as String),
    );
  }
}
