package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.LeaderboardEntryResponse;
import com.kickpro.backend.entity.AgeGroup;
import com.kickpro.backend.entity.LeaderboardType;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.repository.LeaderboardRepository;
import com.kickpro.backend.service.LeaderboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class LeaderboardServiceImpl implements LeaderboardService {

    private static final int LEADERBOARD_LIMIT = 50;

    private final LeaderboardRepository leaderboardRepository;

    @Override
    @Transactional(readOnly = true)
    public List<LeaderboardEntryResponse> getLeaderboard(
            LeaderboardType type,
            Position position,
            String city,
            AgeGroup ageGroup
    ) {
        String cityFilter = city == null || city.isBlank() ? null : city.trim();
        String positionFilter = position == null ? null : position.name();
        LocalDate dobCutoff = resolveDobCutoff(ageGroup);

        List<Object[]> rows = switch (type) {
            case MATCHES -> leaderboardRepository.findTopByMatchCount(
                    LEADERBOARD_LIMIT, cityFilter, positionFilter, dobCutoff);
            case BADGES -> leaderboardRepository.findTopByBadgeCount(
                    LEADERBOARD_LIMIT, cityFilter, positionFilter, dobCutoff);
            case RATINGS -> leaderboardRepository.findTopByAverageRating(
                    LEADERBOARD_LIMIT, cityFilter, positionFilter, dobCutoff);
        };
        return mapRows(rows);
    }

    private LocalDate resolveDobCutoff(AgeGroup ageGroup) {
        if (ageGroup == null || ageGroup == AgeGroup.OPEN) {
            return null;
        }
        return switch (ageGroup) {
            case U18 -> LocalDate.now().minusYears(18);
            case U21 -> LocalDate.now().minusYears(21);
            case OPEN -> null;
        };
    }

    private List<LeaderboardEntryResponse> mapRows(List<Object[]> rows) {
        List<LeaderboardEntryResponse> entries = new ArrayList<>();
        int rank = 1;
        for (Object[] row : rows) {
            entries.add(LeaderboardEntryResponse.builder()
                    .rank(rank++)
                    .playerId(((Number) row[0]).longValue())
                    .playerName((String) row[1])
                    .profilePhotoUrl(row[2] != null ? (String) row[2] : null)
                    .city((String) row[3])
                    .metricValue(((Number) row[4]).doubleValue())
                    .build());
        }
        return entries;
    }
}
