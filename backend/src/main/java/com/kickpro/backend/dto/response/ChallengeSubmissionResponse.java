package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ChallengeSubmissionResponse {

    private Long id;
    private Long challengeId;
    private Long playerId;
    private String playerName;
    private String videoUrl;
    private Integer votes;
    private LocalDateTime submittedAt;
    private Boolean ownSubmission;
}
