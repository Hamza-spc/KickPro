package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateMatchRequest;
import com.kickpro.backend.dto.request.ParticipantReviewRequest;
import com.kickpro.backend.dto.request.PlayerRatingRequest;
import com.kickpro.backend.dto.response.MatchResponse;
import com.kickpro.backend.dto.response.PlayerRatingResponse;
import com.kickpro.backend.service.MatchService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/matches")
@RequiredArgsConstructor
public class MatchController {

    private final MatchService matchService;

    @PostMapping
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<MatchResponse>> createMatch(
            @Valid @RequestBody CreateMatchRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        MatchResponse response = matchService.createMatch(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Match booked successfully"));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MatchResponse>>> getMatches(
            @RequestParam(required = false) String city
    ) {
        List<MatchResponse> matches = matchService.getOpenMatches(city);
        return ResponseEntity.ok(ApiResponse.success(matches, "Matches retrieved successfully"));
    }

    @GetMapping("/open")
    public ResponseEntity<ApiResponse<List<MatchResponse>>> getOpenMatches(
            @RequestParam(required = false) String city
    ) {
        List<MatchResponse> matches = matchService.getOpenMatches(city);
        return ResponseEntity.ok(ApiResponse.success(matches, "Open matches retrieved successfully"));
    }

    @GetMapping("/mine")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<MatchResponse>>> getMyMatches() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<MatchResponse> matches = matchService.getMyMatches(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(matches, "Your matches retrieved successfully"));
    }

    @GetMapping("/{matchId}")
    public ResponseEntity<ApiResponse<MatchResponse>> getMatchById(@PathVariable Long matchId) {
        MatchResponse response = matchService.getMatchById(matchId);
        return ResponseEntity.ok(ApiResponse.success(response, "Match retrieved successfully"));
    }

    @PostMapping("/{matchId}/join")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<MatchResponse>> requestToJoin(@PathVariable Long matchId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        MatchResponse response = matchService.requestToJoin(user.getUserId(), matchId);
        return ResponseEntity.ok(ApiResponse.success(response, "Join request submitted"));
    }

    @PutMapping("/{matchId}/participants/{participantId}/review")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<MatchResponse>> reviewParticipant(
            @PathVariable Long matchId,
            @PathVariable Long participantId,
            @Valid @RequestBody ParticipantReviewRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        MatchResponse response = matchService.reviewParticipant(
                user.getUserId(), matchId, participantId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Participant reviewed successfully"));
    }

    @PutMapping("/{matchId}/complete")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<MatchResponse>> completeMatch(@PathVariable Long matchId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        MatchResponse response = matchService.completeMatch(user.getUserId(), matchId);
        return ResponseEntity.ok(ApiResponse.success(response, "Match marked as completed"));
    }

    @PutMapping("/{matchId}/cancel")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<MatchResponse>> cancelMatch(@PathVariable Long matchId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        MatchResponse response = matchService.cancelMatch(user.getUserId(), matchId);
        return ResponseEntity.ok(ApiResponse.success(response, "Match cancelled"));
    }

    @PostMapping("/{matchId}/ratings")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PlayerRatingResponse>> submitRating(
            @PathVariable Long matchId,
            @Valid @RequestBody PlayerRatingRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerRatingResponse response = matchService.submitRating(user.getUserId(), matchId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Rating submitted successfully"));
    }

    @GetMapping("/{matchId}/ratings")
    public ResponseEntity<ApiResponse<List<PlayerRatingResponse>>> getMatchRatings(
            @PathVariable Long matchId
    ) {
        List<PlayerRatingResponse> ratings = matchService.getMatchRatings(matchId);
        return ResponseEntity.ok(ApiResponse.success(ratings, "Match ratings retrieved successfully"));
    }
}
