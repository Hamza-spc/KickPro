package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.LeaderboardEntryResponse;
import com.kickpro.backend.entity.LeaderboardType;

import java.util.List;

public interface LeaderboardService {

    List<LeaderboardEntryResponse> getLeaderboard(LeaderboardType type);
}
