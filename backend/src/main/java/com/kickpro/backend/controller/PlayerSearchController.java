package com.kickpro.backend.controller;

import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import com.kickpro.backend.service.PlayerSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/scouts/players")
@RequiredArgsConstructor
public class PlayerSearchController {

    private final PlayerSearchService playerSearchService;

    @GetMapping("/search")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Page<PlayerSearchResultResponse>>> searchPlayers(
            @RequestParam(required = false) Position position,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) PreferredFoot preferredFoot,
            @RequestParam(required = false) Integer minAge,
            @RequestParam(required = false) Integer maxAge,
            @RequestParam(required = false) Double minCredibility,
            @RequestParam(required = false) Double maxCredibility,
            @RequestParam(required = false) Integer minDribbling,
            @RequestParam(required = false) Integer minShooting,
            @RequestParam(required = false) Integer minPassing,
            @RequestParam(required = false) Integer minSpeed,
            @RequestParam(required = false) Integer minHeading,
            @RequestParam(required = false) Integer minStamina,
            @RequestParam(required = false) Integer minDrillScore,
            @RequestParam(required = false) Boolean hasCertification,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<PlayerSearchResultResponse> results = playerSearchService.searchPlayers(
                position,
                city,
                preferredFoot,
                minAge,
                maxAge,
                minCredibility,
                maxCredibility,
                minDribbling,
                minShooting,
                minPassing,
                minSpeed,
                minHeading,
                minStamina,
                minDrillScore,
                hasCertification,
                PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "credibilityScore"))
        );
        return ResponseEntity.ok(ApiResponse.success(results, "Players retrieved successfully"));
    }
}
