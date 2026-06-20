package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.GenerateCourseRequest;
import com.kickpro.backend.dto.request.RecoveryPlanRequest;
import com.kickpro.backend.dto.request.ScoutAssistRequest;
import com.kickpro.backend.dto.request.VideoFeedbackRequest;
import com.kickpro.backend.dto.response.AiTextResponse;
import com.kickpro.backend.dto.response.DrillRecommendationResponse;
import com.kickpro.backend.dto.response.GeneratedCourseResponse;
import com.kickpro.backend.dto.response.ScoutAssistResponse;

public interface AiService {

    ScoutAssistResponse scoutAssist(ScoutAssistRequest request);

    AiTextResponse explainScore(Long userId);

    DrillRecommendationResponse recommendDrills(Long userId);

    AiTextResponse generateMealPlan(Long userId);

    AiTextResponse generateRecoveryPlan(Long userId, RecoveryPlanRequest request);

    GeneratedCourseResponse generateCourse(GenerateCourseRequest request);

    AiTextResponse generateVideoFeedback(VideoFeedbackRequest request);
}
