package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateCourseRequest;
import com.kickpro.backend.dto.request.CreateDrillRequest;
import com.kickpro.backend.dto.request.DrillReviewRequest;
import com.kickpro.backend.dto.request.StadiumRequest;
import com.kickpro.backend.dto.request.UpdateCourseRequest;
import com.kickpro.backend.dto.response.AdminDashboardResponse;
import com.kickpro.backend.dto.response.AdminDrillResponse;
import com.kickpro.backend.dto.response.AdminPostResponse;
import com.kickpro.backend.dto.response.AdminUserResponse;
import com.kickpro.backend.dto.response.CourseDetailResponse;
import com.kickpro.backend.dto.response.DrillSubmissionResponse;
import com.kickpro.backend.dto.response.StadiumResponse;
import com.kickpro.backend.service.AdminService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@PreAuthorize("hasRole('ADMIN')")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<AdminDashboardResponse>> getDashboard() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getDashboardStats(), "Dashboard stats retrieved"));
    }

    @GetMapping("/stadiums")
    public ResponseEntity<ApiResponse<List<StadiumResponse>>> listStadiums() {
        return ResponseEntity.ok(ApiResponse.success(adminService.listStadiums(), "Stadiums retrieved"));
    }

    @PostMapping("/stadiums")
    public ResponseEntity<ApiResponse<StadiumResponse>> createStadium(@Valid @RequestBody StadiumRequest request) {
        StadiumResponse response = adminService.createStadium(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response, "Stadium created"));
    }

    @PutMapping("/stadiums/{id}")
    public ResponseEntity<ApiResponse<StadiumResponse>> updateStadium(
            @PathVariable Long id,
            @Valid @RequestBody StadiumRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(adminService.updateStadium(id, request), "Stadium updated"));
    }

    @DeleteMapping("/stadiums/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteStadium(@PathVariable Long id) {
        adminService.deleteStadium(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Stadium deleted"));
    }

    @PostMapping(value = "/stadiums/{id}/photos", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<StadiumResponse>> addStadiumPhotos(
            @PathVariable Long id,
            @RequestPart("files") List<MultipartFile> files
    ) {
        return ResponseEntity.ok(ApiResponse.success(adminService.addStadiumPhotos(id, files), "Photos uploaded"));
    }

    @GetMapping("/drills")
    public ResponseEntity<ApiResponse<List<AdminDrillResponse>>> listDrills() {
        return ResponseEntity.ok(ApiResponse.success(adminService.listDrills(), "Drills retrieved"));
    }

    @PostMapping("/drills")
    public ResponseEntity<ApiResponse<AdminDrillResponse>> createDrill(@Valid @RequestBody CreateDrillRequest request) {
        AdminDrillResponse response = adminService.createDrill(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response, "Drill created"));
    }

    @PutMapping("/drills/{id}")
    public ResponseEntity<ApiResponse<AdminDrillResponse>> updateDrill(
            @PathVariable Long id,
            @Valid @RequestBody CreateDrillRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(adminService.updateDrill(id, request), "Drill updated"));
    }

    @DeleteMapping("/drills/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteDrill(@PathVariable Long id) {
        adminService.deleteDrill(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Drill deleted"));
    }

    @GetMapping("/drills/submissions/pending")
    public ResponseEntity<ApiResponse<List<DrillSubmissionResponse>>> getPendingSubmissions() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getPendingSubmissions(), "Pending submissions retrieved"));
    }

    @PutMapping("/drills/submissions/{submissionId}/review")
    public ResponseEntity<ApiResponse<DrillSubmissionResponse>> reviewSubmission(
            @PathVariable Long submissionId,
            @Valid @RequestBody DrillReviewRequest request
    ) {
        UserPrincipal admin = SecurityUtils.getCurrentUser();
        DrillSubmissionResponse response = adminService.reviewSubmission(admin.getUserId(), submissionId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Submission reviewed"));
    }

    @GetMapping("/courses")
    public ResponseEntity<ApiResponse<List<CourseDetailResponse>>> listCourses() {
        return ResponseEntity.ok(ApiResponse.success(adminService.listCoursesAdmin(), "Courses retrieved"));
    }

    @PostMapping("/courses")
    public ResponseEntity<ApiResponse<CourseDetailResponse>> createCourse(@Valid @RequestBody CreateCourseRequest request) {
        CourseDetailResponse response = adminService.createCourse(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response, "Course created"));
    }

    @PutMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<CourseDetailResponse>> updateCourse(
            @PathVariable Long id,
            @Valid @RequestBody UpdateCourseRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.success(adminService.updateCourse(id, request), "Course updated"));
    }

    @DeleteMapping("/courses/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCourse(@PathVariable Long id) {
        adminService.deleteCourse(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Course deleted"));
    }

    @PostMapping(value = "/courses/{courseId}/lessons/{lessonId}/media", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<CourseDetailResponse>> uploadLessonMedia(
            @PathVariable Long courseId,
            @PathVariable Long lessonId,
            @RequestPart("file") MultipartFile file
    ) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.uploadLessonMedia(courseId, lessonId, file),
                "Lesson media uploaded"));
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<AdminUserResponse>>> listUsers() {
        return ResponseEntity.ok(ApiResponse.success(adminService.listUsers(), "Users retrieved"));
    }

    @PutMapping("/users/{id}/ban")
    public ResponseEntity<ApiResponse<AdminUserResponse>> banUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(adminService.setUserEnabled(id, false), "User banned"));
    }

    @PutMapping("/users/{id}/unban")
    public ResponseEntity<ApiResponse<AdminUserResponse>> unbanUser(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(adminService.setUserEnabled(id, true), "User unbanned"));
    }

    @PutMapping("/users/{id}/verify-agent")
    public ResponseEntity<ApiResponse<AdminUserResponse>> verifyAgent(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(adminService.verifyAgent(id), "Agent verified"));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id) {
        UserPrincipal admin = SecurityUtils.getCurrentUser();
        adminService.deleteUser(admin.getUserId(), id);
        return ResponseEntity.ok(ApiResponse.success(null, "User deleted successfully"));
    }

    @GetMapping("/posts")
    public ResponseEntity<ApiResponse<List<AdminPostResponse>>> listPosts(
            @RequestParam(defaultValue = "false") boolean flaggedOnly
    ) {
        return ResponseEntity.ok(ApiResponse.success(adminService.listPosts(flaggedOnly), "Posts retrieved"));
    }

    @PutMapping("/posts/{id}/flag")
    public ResponseEntity<ApiResponse<AdminPostResponse>> flagPost(
            @PathVariable Long id,
            @RequestBody Map<String, Boolean> body
    ) {
        boolean flagged = body.getOrDefault("flagged", true);
        return ResponseEntity.ok(ApiResponse.success(adminService.flagPost(id, flagged), "Post updated"));
    }

    @DeleteMapping("/posts/{id}")
    public ResponseEntity<ApiResponse<Void>> removePost(@PathVariable Long id) {
        adminService.removePost(id);
        return ResponseEntity.ok(ApiResponse.success(null, "Post removed"));
    }
}
