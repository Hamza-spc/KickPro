package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class PlayerRatingResponse {

    private Long id;
    private Long matchId;
    private Long raterId;
    private String raterName;
    private Long ratedPlayerId;
    private String ratedPlayerName;
    private Integer performanceScore;
    private Integer punctualityScore;
    private Integer teamworkScore;
    private Integer behaviorScore;
    private LocalDateTime ratedAt;
}
