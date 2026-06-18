package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.DrillReviewRequest;
import com.kickpro.backend.dto.response.BadgeResponse;
import com.kickpro.backend.dto.response.DrillProgressionResponse;
import com.kickpro.backend.dto.response.DrillSubmissionResponse;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.service.DrillService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
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

@RestController
@RequestMapping("/api/v1/drills")
@RequiredArgsConstructor
public class DrillController {

    private final DrillService drillService;

    @GetMapping("/progression")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<DrillProgressionResponse>>> getProgression(
            @RequestParam DrillLevel level
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<DrillProgressionResponse> progression = drillService.getProgression(user.getUserId(), level);
        return ResponseEntity.ok(ApiResponse.success(progression, "Drill progression retrieved successfully"));
    }

    @PostMapping(value = "/{drillId}/submit", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<DrillSubmissionResponse>> submitDrill(
            @PathVariable Long drillId,
            @RequestPart("file") MultipartFile file
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        DrillSubmissionResponse response = drillService.submitDrill(user.getUserId(), drillId, file);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Drill submitted for review"));
    }

    @GetMapping("/badges/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<BadgeResponse>>> getMyBadges() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<BadgeResponse> badges = drillService.getMyBadges(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(badges, "Badges retrieved successfully"));
    }

    @GetMapping("/admin/submissions/pending")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<List<DrillSubmissionResponse>>> getPendingSubmissions() {
        List<DrillSubmissionResponse> submissions = drillService.getPendingSubmissions();
        return ResponseEntity.ok(ApiResponse.success(submissions, "Pending submissions retrieved successfully"));
    }

    @PutMapping("/admin/submissions/{submissionId}/review")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<DrillSubmissionResponse>> reviewSubmission(
            @PathVariable Long submissionId,
            @Valid @RequestBody DrillReviewRequest request
    ) {
        UserPrincipal admin = SecurityUtils.getCurrentUser();
        DrillSubmissionResponse response = drillService.reviewSubmission(
                admin.getUserId(), submissionId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Submission reviewed successfully"));
    }
}
