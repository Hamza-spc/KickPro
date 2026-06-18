package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.CreateCourseRequest;
import com.kickpro.backend.dto.request.QuizSubmitRequest;
import com.kickpro.backend.dto.response.CertificationResponse;
import com.kickpro.backend.dto.response.CourseDetailResponse;
import com.kickpro.backend.dto.response.CourseSummaryResponse;
import com.kickpro.backend.dto.response.QuizResponse;
import com.kickpro.backend.dto.response.QuizResultResponse;
import com.kickpro.backend.entity.DrillLevel;

import java.util.List;

public interface CourseService {

    CourseDetailResponse createCourse(CreateCourseRequest request);

    List<CourseSummaryResponse> listCourses(Long userId, DrillLevel level);

    CourseDetailResponse getCourseDetail(Long courseId, Long userId);

    QuizResponse getLessonQuiz(Long courseId, Long lessonId);

    QuizResultResponse submitQuiz(Long userId, Long courseId, Long lessonId, QuizSubmitRequest request);

    List<CertificationResponse> getMyCertifications(Long userId);

    List<CertificationResponse> getPlayerCertifications(Long profileId);
}
