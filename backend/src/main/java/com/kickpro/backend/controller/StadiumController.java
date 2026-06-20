package com.kickpro.backend.controller;

import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.StadiumAvailabilityResponse;
import com.kickpro.backend.dto.response.StadiumResponse;
import com.kickpro.backend.service.StadiumService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/stadiums")
@RequiredArgsConstructor
public class StadiumController {

    private final StadiumService stadiumService;

    @GetMapping
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<StadiumResponse>>> getAllStadiums(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String name
    ) {
        List<StadiumResponse> stadiums = stadiumService.getAllStadiums(city, name);
        return ResponseEntity.ok(ApiResponse.success(stadiums, "Stadiums retrieved successfully"));
    }

    @GetMapping("/{stadiumId}")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<StadiumResponse>> getStadiumById(@PathVariable Long stadiumId) {
        StadiumResponse stadium = stadiumService.getStadiumById(stadiumId);
        return ResponseEntity.ok(ApiResponse.success(stadium, "Stadium retrieved successfully"));
    }

    @GetMapping("/{stadiumId}/availability")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<StadiumAvailabilityResponse>> getAvailability(
            @PathVariable Long stadiumId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date
    ) {
        StadiumAvailabilityResponse availability = stadiumService.getAvailability(stadiumId, date);
        return ResponseEntity.ok(ApiResponse.success(availability, "Stadium availability retrieved successfully"));
    }
}
