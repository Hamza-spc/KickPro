package com.kickpro.backend.controller;

import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.StadiumResponse;
import com.kickpro.backend.service.StadiumService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/stadiums")
@RequiredArgsConstructor
public class StadiumController {

    private final StadiumService stadiumService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<StadiumResponse>>> getAllStadiums() {
        List<StadiumResponse> stadiums = stadiumService.getAllStadiums();
        return ResponseEntity.ok(ApiResponse.success(stadiums, "Stadiums retrieved successfully"));
    }

    @GetMapping("/{stadiumId}")
    public ResponseEntity<ApiResponse<StadiumResponse>> getStadiumById(@PathVariable Long stadiumId) {
        StadiumResponse stadium = stadiumService.getStadiumById(stadiumId);
        return ResponseEntity.ok(ApiResponse.success(stadium, "Stadium retrieved successfully"));
    }
}
