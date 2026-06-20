package com.kickpro.backend.controller;

import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.LeaderboardEntryResponse;
import com.kickpro.backend.entity.AgeGroup;
import com.kickpro.backend.entity.LeaderboardType;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.service.LeaderboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/leaderboard")
@RequiredArgsConstructor
public class LeaderboardController {

    private final LeaderboardService leaderboardService;

    @GetMapping
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT')")
    public ResponseEntity<ApiResponse<List<LeaderboardEntryResponse>>> getLeaderboard(
            @RequestParam LeaderboardType type,
            @RequestParam(required = false) Position position,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) AgeGroup ageGroup
    ) {
        List<LeaderboardEntryResponse> entries = leaderboardService.getLeaderboard(type, position, city, ageGroup);
        return ResponseEntity.ok(ApiResponse.success(entries, "Leaderboard retrieved successfully"));
    }
}
