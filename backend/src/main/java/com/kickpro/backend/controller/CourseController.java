package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateCourseRequest;
import com.kickpro.backend.dto.request.QuizSubmitRequest;
import com.kickpro.backend.dto.response.CertificationResponse;
import com.kickpro.backend.dto.response.CourseDetailResponse;
import com.kickpro.backend.dto.response.CourseSummaryResponse;
import com.kickpro.backend.dto.response.QuizResponse;
import com.kickpro.backend.dto.response.QuizResultResponse;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.service.CourseService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/courses")
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;

    @PostMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<CourseDetailResponse>> createCourse(
            @Valid @RequestBody CreateCourseRequest request
    ) {
        CourseDetailResponse response = courseService.createCourse(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Course created successfully"));
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<CourseSummaryResponse>>> listCourses(
            @RequestParam(required = false) DrillLevel level
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<CourseSummaryResponse> courses = courseService.listCourses(user.getUserId(), level);
        return ResponseEntity.ok(ApiResponse.success(courses, "Courses retrieved successfully"));
    }

    @GetMapping("/{courseId}")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<CourseDetailResponse>> getCourseDetail(@PathVariable Long courseId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        CourseDetailResponse response = courseService.getCourseDetail(courseId, user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Course retrieved successfully"));
    }

    @GetMapping("/{courseId}/lessons/{lessonId}/quiz")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<QuizResponse>> getLessonQuiz(
            @PathVariable Long courseId,
            @PathVariable Long lessonId
    ) {
        QuizResponse response = courseService.getLessonQuiz(courseId, lessonId);
        return ResponseEntity.ok(ApiResponse.success(response, "Quiz retrieved successfully"));
    }

    @PostMapping("/{courseId}/lessons/{lessonId}/quiz/submit")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<QuizResultResponse>> submitQuiz(
            @PathVariable Long courseId,
            @PathVariable Long lessonId,
            @Valid @RequestBody QuizSubmitRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        QuizResultResponse response = courseService.submitQuiz(user.getUserId(), courseId, lessonId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Quiz submitted successfully"));
    }

    @GetMapping("/certifications/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<CertificationResponse>>> getMyCertifications() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<CertificationResponse> certifications = courseService.getMyCertifications(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(certifications, "Certifications retrieved successfully"));
    }

    @GetMapping("/certifications/player/{profileId}")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<CertificationResponse>>> getPlayerCertifications(
            @PathVariable Long profileId
    ) {
        List<CertificationResponse> certifications = courseService.getPlayerCertifications(profileId);
        return ResponseEntity.ok(ApiResponse.success(certifications, "Certifications retrieved successfully"));
    }
}
