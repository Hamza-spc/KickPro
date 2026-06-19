package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class LeaderboardEntryResponse {

    private int rank;
    private Long playerId;
    private String playerName;
    private String profilePhotoUrl;
    private String city;
    private double metricValue;
}
