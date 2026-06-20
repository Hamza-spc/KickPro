package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateWeeklyChallengeRequest;
import com.kickpro.backend.dto.request.SubmitChallengeRequest;
import com.kickpro.backend.dto.response.ChallengeSubmissionResponse;
import com.kickpro.backend.dto.response.WeeklyChallengeResponse;
import com.kickpro.backend.service.ChallengeService;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/challenges")
@RequiredArgsConstructor
public class ChallengeController {

    private final ChallengeService challengeService;

    @GetMapping("/active")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<WeeklyChallengeResponse>> getActiveChallenge() {
        WeeklyChallengeResponse challenge = challengeService.getActiveChallenge();
        return ResponseEntity.ok(ApiResponse.success(challenge, "Active challenge retrieved successfully"));
    }

    @GetMapping("/submissions")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<ChallengeSubmissionResponse>>> getSubmissions() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<ChallengeSubmissionResponse> submissions = challengeService.getSubmissions(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(submissions, "Submissions retrieved successfully"));
    }

    @PostMapping("/submit")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<ChallengeSubmissionResponse>> submit(
            @Valid @RequestBody SubmitChallengeRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ChallengeSubmissionResponse response = challengeService.submit(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Challenge submission created successfully"));
    }

    @PostMapping("/vote/{submissionId}")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<ChallengeSubmissionResponse>> vote(@PathVariable Long submissionId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ChallengeSubmissionResponse response = challengeService.vote(user.getUserId(), submissionId);
        return ResponseEntity.ok(ApiResponse.success(response, "Vote recorded successfully"));
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ApiResponse<WeeklyChallengeResponse>> createChallenge(
            @Valid @RequestBody CreateWeeklyChallengeRequest request
    ) {
        WeeklyChallengeResponse response = challengeService.createChallenge(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Challenge created successfully"));
    }
}
