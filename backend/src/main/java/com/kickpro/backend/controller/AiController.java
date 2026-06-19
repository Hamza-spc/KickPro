package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.GenerateCourseRequest;
import com.kickpro.backend.dto.request.RecoveryPlanRequest;
import com.kickpro.backend.dto.request.ScoutAssistRequest;
import com.kickpro.backend.dto.response.AiTextResponse;
import com.kickpro.backend.dto.response.DrillRecommendationResponse;
import com.kickpro.backend.dto.response.GeneratedCourseResponse;
import com.kickpro.backend.dto.response.ScoutAssistResponse;
import com.kickpro.backend.service.AiService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
public class AiController {

    private final AiService aiService;

    @PostMapping("/scout-assist")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<ScoutAssistResponse>> scoutAssist(
            @Valid @RequestBody ScoutAssistRequest request
    ) {
        ScoutAssistResponse response = aiService.scoutAssist(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Scout assist completed"));
    }

    @PostMapping("/explain-score")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<AiTextResponse>> explainScore() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        AiTextResponse response = aiService.explainScore(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Score explanation generated"));
    }

    @PostMapping("/recommend-drills")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<DrillRecommendationResponse>> recommendDrills() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        DrillRecommendationResponse response = aiService.recommendDrills(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Drill recommendations generated"));
    }

    @PostMapping("/meal-plan")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<AiTextResponse>> mealPlan() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        AiTextResponse response = aiService.generateMealPlan(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Meal plan generated"));
    }

    @PostMapping("/recovery-plan")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<AiTextResponse>> recoveryPlan(
            @Valid @RequestBody RecoveryPlanRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        AiTextResponse response = aiService.generateRecoveryPlan(user.getUserId(), request);
        return ResponseEntity.ok(ApiResponse.success(response, "Recovery plan generated"));
    }

    @PostMapping("/generate-course")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<GeneratedCourseResponse>> generateCourse(
            @Valid @RequestBody GenerateCourseRequest request
    ) {
        GeneratedCourseResponse response = aiService.generateCourse(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Course content generated"));
    }
}
