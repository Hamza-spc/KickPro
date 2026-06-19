import 'package:kickpro/shared/models/course_models.dart';

class LessonViewArgs {
  const LessonViewArgs({
    required this.lesson,
    required this.courseId,
    required this.courseTitle,
    required this.courseCertified,
  });

  final LessonSummary lesson;
  final int courseId;
  final String courseTitle;
  final bool courseCertified;
}
