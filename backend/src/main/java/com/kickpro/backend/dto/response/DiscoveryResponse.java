package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class DiscoveryResponse {

    private long playersNearby;
    private long openMatches;
    private List<MatchResponse> upcomingInCity;
    private List<DiscoveryPlayerSummary> topPlayers;

    @Getter
    @Builder
    public static class DiscoveryPlayerSummary {
        private Long playerId;
        private String playerName;
        private String profilePhotoUrl;
        private String city;
        private double credibilityScore;
    }
}
