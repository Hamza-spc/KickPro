package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.BadgeType;
import com.kickpro.backend.entity.SubmissionStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class DrillSubmissionResponse {

    private Long id;
    private Long playerId;
    private String playerName;
    private Long drillId;
    private String drillTitle;
    private String videoCloudinaryUrl;
    private SubmissionStatus status;
    private Integer score;
    private LocalDateTime submittedAt;
    private LocalDateTime reviewedAt;
    private Long reviewedBy;
}
