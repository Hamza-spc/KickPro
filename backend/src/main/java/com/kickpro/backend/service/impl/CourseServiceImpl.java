package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateCourseRequest;
import com.kickpro.backend.dto.request.QuizSubmitRequest;
import com.kickpro.backend.dto.response.CertificationResponse;
import com.kickpro.backend.dto.response.CourseDetailResponse;
import com.kickpro.backend.dto.response.CourseSummaryResponse;
import com.kickpro.backend.dto.response.QuizResponse;
import com.kickpro.backend.dto.response.QuizResultResponse;
import com.kickpro.backend.entity.Certification;
import com.kickpro.backend.entity.Course;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.Lesson;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Quiz;
import com.kickpro.backend.entity.QuizQuestion;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.CourseRepository;
import com.kickpro.backend.repository.LessonRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.service.CourseService;
import com.kickpro.backend.service.CredibilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class CourseServiceImpl implements CourseService {

    private static final String DEFAULT_BADGE_URL =
            "https://res.cloudinary.com/demo/image/upload/kickpro/cert-badge.png";

    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final CertificationRepository certificationRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final CredibilityService credibilityService;

    @Override
    @Transactional
    public CourseDetailResponse createCourse(CreateCourseRequest request) {
        validateLessons(request.getLessons());

        Course course = Course.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .level(request.getLevel())
                .build();

        for (CreateCourseRequest.CreateLessonRequest lessonRequest : request.getLessons()) {
            Lesson lesson = Lesson.builder()
                    .course(course)
                    .title(lessonRequest.getTitle().trim())
                    .content(lessonRequest.getContent().trim())
                    .orderIndex(lessonRequest.getOrderIndex())
                    .build();
            course.getLessons().add(lesson);

            if (lessonRequest.getQuiz() != null) {
                validateQuizQuestions(lessonRequest.getQuiz().getQuestions());
                Quiz quiz = Quiz.builder().lesson(lesson).build();
                lesson.setQuiz(quiz);

                for (CreateCourseRequest.CreateQuizQuestionRequest questionRequest
                        : lessonRequest.getQuiz().getQuestions()) {
                    QuizQuestion question = QuizQuestion.builder()
                            .quiz(quiz)
                            .question(questionRequest.getQuestion().trim())
                            .options(questionRequest.getOptions())
                            .correctAnswerIndex(questionRequest.getCorrectAnswerIndex())
                            .build();
                    quiz.getQuestions().add(question);
                }
            }
        }

        Course saved = courseRepository.save(course);
        return toCourseDetail(saved, Set.of());
    }

    @Override
    @Transactional(readOnly = true)
    public List<CourseSummaryResponse> listCourses(Long userId, DrillLevel level) {
        Set<Long> certifiedCourseIds = resolveCertifiedCourseIds(userId);
        List<Course> courses = level == null
                ? courseRepository.findAllByOrderByTitleAsc()
                : courseRepository.findByLevelOrderByTitleAsc(level);

        return courses.stream()
                .map(course -> toCourseSummary(course, certifiedCourseIds.contains(course.getId())))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public CourseDetailResponse getCourseDetail(Long courseId, Long userId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));
        Set<Long> certifiedCourseIds = resolveCertifiedCourseIds(userId);
        return toCourseDetail(course, certifiedCourseIds);
    }

    @Override
    @Transactional(readOnly = true)
    public QuizResponse getLessonQuiz(Long courseId, Long lessonId) {
        Lesson lesson = loadLesson(courseId, lessonId);
        Quiz quiz = lesson.getQuiz();
        if (quiz == null) {
            throw new ResourceNotFoundException("This lesson has no quiz");
        }

        return QuizResponse.builder()
                .id(quiz.getId())
                .lessonId(lesson.getId())
                .courseId(courseId)
                .questions(quiz.getQuestions().stream()
                        .map(question -> QuizResponse.QuizQuestionResponse.builder()
                                .id(question.getId())
                                .question(question.getQuestion())
                                .options(question.getOptions())
                                .build())
                        .toList())
                .build();
    }

    @Override
    @Transactional
    public QuizResultResponse submitQuiz(
            Long userId,
            Long courseId,
            Long lessonId,
            QuizSubmitRequest request
    ) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        Lesson lesson = loadLesson(courseId, lessonId);
        Quiz quiz = lesson.getQuiz();
        if (quiz == null) {
            throw new BadRequestException("This lesson has no quiz");
        }

        Map<Long, QuizQuestion> questionsById = new HashMap<>();
        for (QuizQuestion question : quiz.getQuestions()) {
            questionsById.put(question.getId(), question);
        }

        if (request.getAnswers().size() != questionsById.size()) {
            throw new BadRequestException("All quiz questions must be answered");
        }

        int correctCount = 0;
        Set<Long> answeredQuestionIds = new HashSet<>();
        for (QuizSubmitRequest.AnswerSubmission answer : request.getAnswers()) {
            if (!answeredQuestionIds.add(answer.getQuestionId())) {
                throw new BadRequestException("Duplicate answer for question " + answer.getQuestionId());
            }

            QuizQuestion question = questionsById.get(answer.getQuestionId());
            if (question == null) {
                throw new BadRequestException("Invalid question id: " + answer.getQuestionId());
            }

            if (answer.getSelectedOptionIndex() < 0
                    || answer.getSelectedOptionIndex() >= question.getOptions().size()) {
                throw new BadRequestException("Invalid option index for question " + question.getId());
            }

            if (answer.getSelectedOptionIndex().equals(question.getCorrectAnswerIndex())) {
                correctCount++;
            }
        }

        int totalQuestions = questionsById.size();
        int scorePercent = (correctCount * 100) / totalQuestions;
        boolean passed = CredibilityServiceImpl.isPassingQuizScore(correctCount, totalQuestions);

        CertificationResponse certificationResponse = null;
        boolean certificationEarned = false;

        if (passed && isFinalLesson(lesson)) {
            if (!certificationRepository.existsByPlayerIdAndCourseId(player.getId(), courseId)) {
                Certification certification = Certification.builder()
                        .player(player)
                        .course(lesson.getCourse())
                        .badgeUrl(DEFAULT_BADGE_URL)
                        .build();
                Certification saved = certificationRepository.save(certification);
                credibilityService.recalculateForPlayer(player.getId());
                certificationEarned = true;
                certificationResponse = toCertificationResponse(saved);
            }
        }

        return QuizResultResponse.builder()
                .passed(passed)
                .scorePercent(scorePercent)
                .correctCount(correctCount)
                .totalQuestions(totalQuestions)
                .certificationEarned(certificationEarned)
                .certification(certificationResponse)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<CertificationResponse> getMyCertifications(Long userId) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return getPlayerCertifications(player.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<CertificationResponse> getPlayerCertifications(Long profileId) {
        if (!playerProfileRepository.existsById(profileId)) {
            throw new ResourceNotFoundException("Player profile not found");
        }

        return certificationRepository.findByPlayerIdOrderByEarnedAtDesc(profileId).stream()
                .map(this::toCertificationResponse)
                .toList();
    }

    private Lesson loadLesson(Long courseId, Long lessonId) {
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResourceNotFoundException("Lesson not found"));
        if (!lesson.getCourse().getId().equals(courseId)) {
            throw new BadRequestException("Lesson does not belong to this course");
        }
        return lesson;
    }

    private boolean isFinalLesson(Lesson lesson) {
        return lessonRepository.findTopByCourseIdOrderByOrderIndexDesc(lesson.getCourse().getId())
                .map(finalLesson -> finalLesson.getId().equals(lesson.getId()))
                .orElse(false);
    }

    private Set<Long> resolveCertifiedCourseIds(Long userId) {
        if (userId == null) {
            return Set.of();
        }
        return playerProfileRepository.findByUserId(userId)
                .map(profile -> certificationRepository.findByPlayerIdOrderByEarnedAtDesc(profile.getId()).stream()
                        .map(cert -> cert.getCourse().getId())
                        .collect(java.util.stream.Collectors.toSet()))
                .orElse(Set.of());
    }

    private void validateLessons(List<CreateCourseRequest.CreateLessonRequest> lessons) {
        Set<Integer> orderIndexes = new HashSet<>();
        boolean hasQuiz = false;
        int maxOrder = lessons.stream()
                .map(CreateCourseRequest.CreateLessonRequest::getOrderIndex)
                .max(Integer::compareTo)
                .orElse(0);

        for (CreateCourseRequest.CreateLessonRequest lesson : lessons) {
            if (!orderIndexes.add(lesson.getOrderIndex())) {
                throw new BadRequestException("Duplicate lesson order index: " + lesson.getOrderIndex());
            }
            if (lesson.getOrderIndex() == maxOrder) {
                if (lesson.getQuiz() == null || lesson.getQuiz().getQuestions().isEmpty()) {
                    throw new BadRequestException("Final lesson must include a quiz");
                }
                hasQuiz = true;
            }
        }

        if (!hasQuiz) {
            throw new BadRequestException("Course must include at least one lesson with a final quiz");
        }
    }

    private void validateQuizQuestions(List<CreateCourseRequest.CreateQuizQuestionRequest> questions) {
        if (questions == null || questions.isEmpty()) {
            throw new BadRequestException("Quiz must contain at least one question");
        }

        for (CreateCourseRequest.CreateQuizQuestionRequest question : questions) {
            if (question.getCorrectAnswerIndex() < 0
                    || question.getCorrectAnswerIndex() >= question.getOptions().size()) {
                throw new BadRequestException("Invalid correct answer index for question: " + question.getQuestion());
            }
        }
    }

    private CourseSummaryResponse toCourseSummary(Course course, boolean certified) {
        return CourseSummaryResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .level(course.getLevel())
                .lessonCount(course.getLessons().size())
                .certified(certified)
                .createdAt(course.getCreatedAt())
                .build();
    }

    private CourseDetailResponse toCourseDetail(Course course, Set<Long> certifiedCourseIds) {
        List<Lesson> sortedLessons = course.getLessons().stream()
                .sorted(Comparator.comparing(Lesson::getOrderIndex))
                .toList();

        int maxOrder = sortedLessons.stream()
                .map(Lesson::getOrderIndex)
                .max(Integer::compareTo)
                .orElse(0);

        return CourseDetailResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .level(course.getLevel())
                .certified(certifiedCourseIds.contains(course.getId()))
                .lessons(sortedLessons.stream()
                        .map(lesson -> CourseDetailResponse.LessonSummaryResponse.builder()
                                .id(lesson.getId())
                                .title(lesson.getTitle())
                                .content(lesson.getContent())
                                .orderIndex(lesson.getOrderIndex())
                                .hasQuiz(lesson.getQuiz() != null)
                                .finalLesson(lesson.getOrderIndex().equals(maxOrder))
                                .build())
                        .toList())
                .createdAt(course.getCreatedAt())
                .build();
    }

    private CertificationResponse toCertificationResponse(Certification certification) {
        return CertificationResponse.builder()
                .id(certification.getId())
                .courseId(certification.getCourse().getId())
                .courseTitle(certification.getCourse().getTitle())
                .badgeUrl(certification.getBadgeUrl())
                .earnedAt(certification.getEarnedAt())
                .build();
    }
}
