package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.DrillReviewRequest;
import com.kickpro.backend.dto.response.BadgeResponse;
import com.kickpro.backend.dto.response.DrillProgressionResponse;
import com.kickpro.backend.dto.response.DrillSubmissionResponse;
import com.kickpro.backend.entity.DrillLevel;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface DrillService {

    List<DrillProgressionResponse> getProgression(Long userId, DrillLevel level);

    DrillSubmissionResponse submitDrill(Long userId, Long drillId, MultipartFile file);

    List<BadgeResponse> getMyBadges(Long userId);

    List<DrillSubmissionResponse> getPendingSubmissions();

    DrillSubmissionResponse reviewSubmission(Long adminUserId, Long submissionId, DrillReviewRequest request);
}
