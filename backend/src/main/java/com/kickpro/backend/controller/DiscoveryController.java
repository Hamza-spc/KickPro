package com.kickpro.backend.controller;

import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.response.DiscoveryResponse;
import com.kickpro.backend.service.DiscoveryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/discovery")
@RequiredArgsConstructor
public class DiscoveryController {

    private final DiscoveryService discoveryService;

    @GetMapping
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<DiscoveryResponse>> getDiscovery(
            @RequestParam String city
    ) {
        DiscoveryResponse response = discoveryService.getDiscovery(city);
        return ResponseEntity.ok(ApiResponse.success(response, "Discovery data retrieved successfully"));
    }
}
