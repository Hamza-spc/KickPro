package com.kickpro.backend.service.impl;

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
import com.kickpro.backend.entity.Course;
import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.Lesson;
import com.kickpro.backend.entity.LessonMediaType;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.Role;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.CourseRepository;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.LessonRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.AdminService;
import com.kickpro.backend.service.AdminUserDeletionService;
import com.kickpro.backend.service.CourseService;
import com.kickpro.backend.service.DrillService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminServiceImpl implements AdminService {

    private final StadiumRepository stadiumRepository;
    private final DrillRepository drillRepository;
    private final DrillService drillService;
    private final CourseService courseService;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final VideoRepository videoRepository;
    private final MatchRepository matchRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final CloudinaryService cloudinaryService;
    private final AdminUserDeletionService adminUserDeletionService;

    @Override
    @Transactional(readOnly = true)
    public AdminDashboardResponse getDashboardStats() {
        return AdminDashboardResponse.builder()
                .totalPlayers(playerProfileRepository.count())
                .pendingDrillSubmissions(drillSubmissionRepository.countByStatus(SubmissionStatus.PENDING))
                .activeMatches(matchRepository.countByStatusIn(List.of(MatchStatus.OPEN, MatchStatus.FULL)))
                .totalUsers(userRepository.count())
                .flaggedPosts(videoRepository.countByFlaggedTrue())
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<StadiumResponse> listStadiums() {
        return stadiumRepository.findAll().stream().map(this::toStadiumResponse).toList();
    }

    @Override
    @Transactional
    public StadiumResponse createStadium(StadiumRequest request) {
        Stadium stadium = applyStadiumFields(Stadium.builder().build(), request);
        return toStadiumResponse(stadiumRepository.save(stadium));
    }

    @Override
    @Transactional
    public StadiumResponse updateStadium(Long id, StadiumRequest request) {
        Stadium stadium = stadiumRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Stadium not found"));
        applyStadiumFields(stadium, request);
        return toStadiumResponse(stadiumRepository.save(stadium));
    }

    @Override
    @Transactional
    public void deleteStadium(Long id) {
        if (!stadiumRepository.existsById(id)) {
            throw new ResourceNotFoundException("Stadium not found");
        }
        stadiumRepository.deleteById(id);
    }

    @Override
    @Transactional
    public StadiumResponse addStadiumPhotos(Long id, List<MultipartFile> files) {
        Stadium stadium = stadiumRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Stadium not found"));
        if (files == null || files.isEmpty()) {
            throw new BadRequestException("At least one photo is required");
        }
        List<String> photos = stadium.getPhotos();
        if (photos == null) {
            photos = new ArrayList<>();
            stadium.setPhotos(photos);
        }
        for (MultipartFile file : files) {
            if (file == null || file.isEmpty()) {
                continue;
            }
            try {
                String publicId = "stadium-" + id + "-" + System.currentTimeMillis();
                photos.add(cloudinaryService.uploadImage(file, "kickpro/stadiums", publicId));
            } catch (IOException ex) {
                throw new BadRequestException("Failed to upload stadium photo");
            }
        }
        Stadium saved = stadiumRepository.save(stadium);
        stadiumRepository.flush();
        return toStadiumResponse(stadiumRepository.findById(saved.getId()).orElse(saved));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminDrillResponse> listDrills() {
        return drillRepository.findAll().stream().map(this::toDrillResponse).toList();
    }

    @Override
    @Transactional
    public AdminDrillResponse createDrill(CreateDrillRequest request) {
        Drill drill = Drill.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .rules(request.getRules().trim())
                .level(request.getLevel())
                .progressionOrder(request.getProgressionOrder())
                .targetSkill(request.getTargetSkill())
                .build();
        if (request.getParentDrillId() != null) {
            Drill parent = drillRepository.findById(request.getParentDrillId())
                    .orElseThrow(() -> new ResourceNotFoundException("Parent drill not found"));
            drill.setParentDrill(parent);
        }
        return toDrillResponse(drillRepository.save(drill));
    }

    @Override
    @Transactional
    public AdminDrillResponse updateDrill(Long id, CreateDrillRequest request) {
        Drill drill = drillRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Drill not found"));
        drill.setTitle(request.getTitle().trim());
        drill.setDescription(request.getDescription().trim());
        drill.setRules(request.getRules().trim());
        drill.setLevel(request.getLevel());
        drill.setProgressionOrder(request.getProgressionOrder());
        drill.setTargetSkill(request.getTargetSkill());
        if (request.getParentDrillId() != null) {
            Drill parent = drillRepository.findById(request.getParentDrillId())
                    .orElseThrow(() -> new ResourceNotFoundException("Parent drill not found"));
            drill.setParentDrill(parent);
        } else {
            drill.setParentDrill(null);
        }
        return toDrillResponse(drillRepository.save(drill));
    }

    @Override
    @Transactional
    public void deleteDrill(Long id) {
        if (!drillRepository.existsById(id)) {
            throw new ResourceNotFoundException("Drill not found");
        }
        drillRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public List<DrillSubmissionResponse> getPendingSubmissions() {
        return drillService.getPendingSubmissions();
    }

    @Override
    @Transactional
    public DrillSubmissionResponse reviewSubmission(Long adminUserId, Long submissionId, DrillReviewRequest request) {
        return drillService.reviewSubmission(adminUserId, submissionId, request);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CourseDetailResponse> listCoursesAdmin() {
        return courseRepository.findAll().stream()
                .map(course -> courseService.getCourseDetail(course.getId(), null))
                .toList();
    }

    @Override
    @Transactional
    public CourseDetailResponse createCourse(CreateCourseRequest request) {
        return courseService.createCourse(request);
    }

    @Override
    @Transactional
    public CourseDetailResponse updateCourse(Long id, UpdateCourseRequest request) {
        Course course = courseRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Course not found"));
        course.setTitle(request.getTitle().trim());
        course.setDescription(request.getDescription().trim());
        course.setLevel(request.getLevel());
        courseRepository.save(course);
        return courseService.getCourseDetail(id, null);
    }

    @Override
    @Transactional
    public void deleteCourse(Long id) {
        if (!courseRepository.existsById(id)) {
            throw new ResourceNotFoundException("Course not found");
        }
        courseRepository.deleteById(id);
    }

    @Override
    @Transactional
    public CourseDetailResponse uploadLessonMedia(Long courseId, Long lessonId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Media file is required");
        }
        Lesson lesson = lessonRepository.findById(lessonId)
                .orElseThrow(() -> new ResourceNotFoundException("Lesson not found"));
        if (!lesson.getCourse().getId().equals(courseId)) {
            throw new BadRequestException("Lesson does not belong to this course");
        }

        LessonMediaType mediaType = resolveMediaType(file);
        try {
            String publicId = "lesson-" + lessonId + "-" + System.currentTimeMillis();
            String url = switch (mediaType) {
                case VIDEO -> cloudinaryService.uploadVideo(file, "kickpro/lesson-media", publicId);
                case IMAGE -> cloudinaryService.uploadImage(file, "kickpro/lesson-media", publicId);
                case DOCUMENT -> cloudinaryService.uploadRaw(file, "kickpro/lesson-media", publicId);
            };
            lesson.setMediaUrl(url);
            lesson.setMediaType(mediaType);
            lessonRepository.save(lesson);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload lesson media");
        }
        return courseService.getCourseDetail(courseId, null);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminUserResponse> listUsers() {
        return userRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toUserResponse)
                .toList();
    }

    @Override
    @Transactional
    public AdminUserResponse setUserEnabled(Long userId, boolean enabled) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (user.getRole() == Role.ADMIN) {
            throw new BadRequestException("Admin accounts cannot be banned");
        }
        user.setEnabled(enabled);
        return toUserResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public AdminUserResponse verifyAgent(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (user.getRole() != Role.AGENT) {
            throw new BadRequestException("Only agent accounts can be verified");
        }
        user.setAgentVerified(true);
        return toUserResponse(userRepository.save(user));
    }

    @Override
    @Transactional
    public void deleteUser(Long adminUserId, Long targetUserId) {
        adminUserDeletionService.deleteUser(adminUserId, targetUserId);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminPostResponse> listPosts(boolean flaggedOnly) {
        List<Video> posts = flaggedOnly
                ? videoRepository.findByFlaggedTrueOrderByUploadedAtDesc()
                : videoRepository.findAllByOrderByUploadedAtDesc();
        return posts.stream().map(this::toPostResponse).toList();
    }

    @Override
    @Transactional
    public AdminPostResponse flagPost(Long postId, boolean flagged) {
        Video post = videoRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        post.setFlagged(flagged);
        return toPostResponse(videoRepository.save(post));
    }

    @Override
    @Transactional
    public void removePost(Long postId) {
        Video post = videoRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found"));
        post.setHidden(true);
        videoRepository.save(post);
    }

    private Stadium applyStadiumFields(Stadium stadium, StadiumRequest request) {
        stadium.setName(request.getName().trim());
        stadium.setLocation(request.getLocation().trim());
        if (request.getCity() != null && !request.getCity().isBlank()) {
            stadium.setCity(request.getCity().trim());
        } else if (stadium.getCity() == null || stadium.getCity().isBlank()) {
            stadium.setCity("Casablanca");
        }
        stadium.setPhoneNumber(request.getPhoneNumber() == null ? null : request.getPhoneNumber().trim());
        stadium.setDescription(request.getDescription());
        stadium.setPricePerHour(request.getPricePerHour());
        stadium.setPitchCount(request.getPitchCount());
        stadium.setPitchTypes(request.getPitchTypes() == null ? List.of() : request.getPitchTypes());
        stadium.setAllowedFormats(request.getAllowedFormats() == null ? List.of() : request.getAllowedFormats());
        stadium.setOpenTime(request.getOpenTime());
        stadium.setCloseTime(request.getCloseTime());
        stadium.setGrassType(request.getGrassType());
        stadium.setLatitude(request.getLatitude());
        stadium.setLongitude(request.getLongitude());
        return stadium;
    }

    private LessonMediaType resolveMediaType(MultipartFile file) {
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase();
        if (contentType.startsWith("video/")) {
            return LessonMediaType.VIDEO;
        }
        if (contentType.startsWith("image/")) {
            return LessonMediaType.IMAGE;
        }
        return LessonMediaType.DOCUMENT;
    }

    private StadiumResponse toStadiumResponse(Stadium stadium) {
        return StadiumResponse.builder()
                .id(stadium.getId())
                .name(stadium.getName())
                .location(stadium.getLocation())
                .city(stadium.getCity())
                .phoneNumber(stadium.getPhoneNumber())
                .description(stadium.getDescription())
                .pricePerHour(stadium.getPricePerHour())
                .pitchCount(stadium.getPitchCount())
                .pitchTypes(List.copyOf(stadium.getPitchTypes()))
                .allowedFormats(List.copyOf(stadium.getAllowedFormats()))
                .openTime(stadium.getOpenTime())
                .closeTime(stadium.getCloseTime())
                .grassType(stadium.getGrassType())
                .latitude(stadium.getLatitude())
                .longitude(stadium.getLongitude())
                .photos(List.copyOf(stadium.getPhotos()))
                .build();
    }

    private AdminDrillResponse toDrillResponse(Drill drill) {
        return AdminDrillResponse.builder()
                .id(drill.getId())
                .title(drill.getTitle())
                .description(drill.getDescription())
                .rules(drill.getRules())
                .level(drill.getLevel())
                .progressionOrder(drill.getProgressionOrder())
                .parentDrillId(drill.getParentDrill() == null ? null : drill.getParentDrill().getId())
                .targetSkill(drill.getTargetSkill())
                .build();
    }

    private AdminUserResponse toUserResponse(User user) {
        return AdminUserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .role(user.getRole())
                .enabled(user.getEnabled())
                .agentVerified(user.getAgentVerified())
                .createdAt(user.getCreatedAt())
                .build();
    }

    private AdminPostResponse toPostResponse(Video post) {
        return AdminPostResponse.builder()
                .id(post.getId())
                .playerId(post.getPlayer().getId())
                .playerName(post.getPlayer().getFullName())
                .title(post.getTitle())
                .cloudinaryUrl(post.getCloudinaryUrl())
                .postType(post.getPostType())
                .skillTag(post.getSkillTag())
                .flagged(post.getFlagged())
                .hidden(post.getHidden())
                .uploadedAt(post.getUploadedAt())
                .build();
    }
}
