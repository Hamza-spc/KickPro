package com.kickpro.backend.service;

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
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface AdminService {

    AdminDashboardResponse getDashboardStats();

    List<StadiumResponse> listStadiums();

    StadiumResponse createStadium(StadiumRequest request);

    StadiumResponse updateStadium(Long id, StadiumRequest request);

    void deleteStadium(Long id);

    StadiumResponse addStadiumPhotos(Long id, List<MultipartFile> files);

    List<AdminDrillResponse> listDrills();

    AdminDrillResponse createDrill(CreateDrillRequest request);

    AdminDrillResponse updateDrill(Long id, CreateDrillRequest request);

    void deleteDrill(Long id);

    List<DrillSubmissionResponse> getPendingSubmissions();

    DrillSubmissionResponse reviewSubmission(Long adminUserId, Long submissionId, DrillReviewRequest request);

    List<CourseDetailResponse> listCoursesAdmin();

    CourseDetailResponse createCourse(CreateCourseRequest request);

    CourseDetailResponse updateCourse(Long id, UpdateCourseRequest request);

    void deleteCourse(Long id);

    CourseDetailResponse uploadLessonMedia(Long courseId, Long lessonId, MultipartFile file);

    List<AdminUserResponse> listUsers();

    AdminUserResponse setUserEnabled(Long userId, boolean enabled);

    AdminUserResponse verifyAgent(Long userId);

    void deleteUser(Long adminUserId, Long targetUserId);

    List<AdminPostResponse> listPosts(boolean flaggedOnly);

    AdminPostResponse flagPost(Long postId, boolean flagged);

    void removePost(Long postId);
}
