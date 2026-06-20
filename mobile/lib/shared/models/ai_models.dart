class AiTextResponse {
  const AiTextResponse({required this.content});

  final String content;

  factory AiTextResponse.fromJson(Map<String, dynamic> json) {
    return AiTextResponse(content: json['content'] as String? ?? '');
  }
}

class ScoutAssistResponse {
  const ScoutAssistResponse({
    required this.matchedPlayerIds,
    required this.explanation,
  });

  final List<int> matchedPlayerIds;
  final String explanation;

  factory ScoutAssistResponse.fromJson(Map<String, dynamic> json) {
    return ScoutAssistResponse(
      matchedPlayerIds: (json['matchedPlayerIds'] as List<dynamic>? ?? [])
          .map((id) => (id as num).toInt())
          .toList(),
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class DrillRecommendation {
  const DrillRecommendation({
    required this.drillId,
    required this.drillTitle,
    required this.targetSkill,
    required this.level,
    required this.reason,
  });

  final int drillId;
  final String drillTitle;
  final String targetSkill;
  final String level;
  final String reason;

  factory DrillRecommendation.fromJson(Map<String, dynamic> json) {
    return DrillRecommendation(
      drillId: (json['drillId'] as num).toInt(),
      drillTitle: json['drillTitle'] as String? ?? '',
      targetSkill: json['targetSkill'] as String? ?? '',
      level: json['level'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class DrillRecommendationResponse {
  const DrillRecommendationResponse({
    required this.recommendations,
    required this.summary,
  });

  final List<DrillRecommendation> recommendations;
  final String summary;

  factory DrillRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return DrillRecommendationResponse(
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((item) => DrillRecommendation.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] as String? ?? '',
    );
  }
}

class RecoveryPlanRequest {
  const RecoveryPlanRequest({
    required this.injuryType,
    required this.bodyPart,
    required this.severity,
  });

  final String injuryType;
  final String bodyPart;
  final String severity;

  Map<String, dynamic> toJson() => {
        'injuryType': injuryType,
        'bodyPart': bodyPart,
        'severity': severity,
      };
}

class GeneratedCourseQuestion {
  const GeneratedCourseQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  factory GeneratedCourseQuestion.fromJson(Map<String, dynamic> json) {
    return GeneratedCourseQuestion(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? []).map((o) => o as String).toList(),
      correctAnswerIndex: (json['correctAnswerIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class GeneratedCourseQuiz {
  const GeneratedCourseQuiz({required this.questions});

  final List<GeneratedCourseQuestion> questions;

  factory GeneratedCourseQuiz.fromJson(Map<String, dynamic> json) {
    return GeneratedCourseQuiz(
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => GeneratedCourseQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GeneratedCourseLesson {
  const GeneratedCourseLesson({
    required this.title,
    required this.content,
    required this.orderIndex,
    this.quiz,
  });

  final String title;
  final String content;
  final int orderIndex;
  final GeneratedCourseQuiz? quiz;

  factory GeneratedCourseLesson.fromJson(Map<String, dynamic> json) {
    return GeneratedCourseLesson(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      quiz: json['quiz'] == null
          ? null
          : GeneratedCourseQuiz.fromJson(json['quiz'] as Map<String, dynamic>),
    );
  }
}

class GeneratedCourseResponse {
  const GeneratedCourseResponse({
    required this.title,
    required this.description,
    required this.level,
    required this.lessons,
  });

  final String title;
  final String description;
  final String level;
  final List<GeneratedCourseLesson> lessons;

  factory GeneratedCourseResponse.fromJson(Map<String, dynamic> json) {
    return GeneratedCourseResponse(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      level: json['level'] as String? ?? '',
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((l) => GeneratedCourseLesson.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum AiTextAction { explainScore, mealPlan, videoFeedback }

class VideoFeedbackParams {
  const VideoFeedbackParams({required this.videoUrl, this.skillTag});

  final String videoUrl;
  final String? skillTag;
}
