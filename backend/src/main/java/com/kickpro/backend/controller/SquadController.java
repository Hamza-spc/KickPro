package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateSquadRequest;
import com.kickpro.backend.dto.response.SquadDiscoverResponse;
import com.kickpro.backend.dto.response.SquadJoinRequestResponse;
import com.kickpro.backend.dto.response.SquadResponse;
import com.kickpro.backend.service.SquadService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/squads")
@RequiredArgsConstructor
public class SquadController {

    private final SquadService squadService;

    @PostMapping
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadResponse>> createSquad(
            @Valid @RequestBody CreateSquadRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadResponse response = squadService.createSquad(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Squad created successfully"));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<SquadResponse>>> getMySquads() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<SquadResponse> squads = squadService.getMySquads(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(squads, "Squads retrieved successfully"));
    }

    @GetMapping("/discover")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<SquadDiscoverResponse>>> discoverSquads(
            @RequestParam String city
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<SquadDiscoverResponse> squads = squadService.discoverSquads(user.getUserId(), city);
        return ResponseEntity.ok(ApiResponse.success(squads, "Squads discovered successfully"));
    }

    @GetMapping("/join-requests/incoming")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<SquadJoinRequestResponse>>> getIncomingJoinRequests() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<SquadJoinRequestResponse> requests = squadService.getIncomingJoinRequests(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(requests, "Join requests retrieved successfully"));
    }

    @PostMapping("/join-requests/{requestId}/approve")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadJoinRequestResponse>> approveJoinRequest(
            @PathVariable Long requestId
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadJoinRequestResponse response = squadService.approveJoinRequest(user.getUserId(), requestId);
        return ResponseEntity.ok(ApiResponse.success(response, "Join request approved"));
    }

    @PostMapping("/join-requests/{requestId}/reject")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadJoinRequestResponse>> rejectJoinRequest(
            @PathVariable Long requestId
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadJoinRequestResponse response = squadService.rejectJoinRequest(user.getUserId(), requestId);
        return ResponseEntity.ok(ApiResponse.success(response, "Join request rejected"));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadResponse>> getSquadById(@PathVariable Long id) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadResponse response = squadService.getSquadById(user.getUserId(), id);
        return ResponseEntity.ok(ApiResponse.success(response, "Squad retrieved successfully"));
    }

    @PostMapping("/{id}/join-requests")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadJoinRequestResponse>> requestJoin(@PathVariable Long id) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadJoinRequestResponse response = squadService.requestJoin(user.getUserId(), id);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Join request sent successfully"));
    }

    @PostMapping("/{id}/invite/{profileId}")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SquadResponse>> invitePlayer(
            @PathVariable Long id,
            @PathVariable Long profileId
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SquadResponse response = squadService.invitePlayer(user.getUserId(), id, profileId);
        return ResponseEntity.ok(ApiResponse.success(response, "Player invited to squad"));
    }
}
