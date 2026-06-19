package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AdminDashboardResponse {

    private long totalPlayers;
    private long pendingDrillSubmissions;
    private long activeMatches;
    private long totalUsers;
    private long flaggedPosts;
}
