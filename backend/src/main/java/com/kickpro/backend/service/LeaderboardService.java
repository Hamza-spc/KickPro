package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.LeaderboardEntryResponse;
import com.kickpro.backend.entity.AgeGroup;
import com.kickpro.backend.entity.LeaderboardType;
import com.kickpro.backend.entity.Position;

import java.util.List;

public interface LeaderboardService {

    List<LeaderboardEntryResponse> getLeaderboard(
            LeaderboardType type,
            Position position,
            String city,
            AgeGroup ageGroup
    );
}
