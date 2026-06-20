package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.ApplyReferralRequest;
import com.kickpro.backend.dto.response.ReferralResponse;
import com.kickpro.backend.service.ReferralService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/referrals")
@RequiredArgsConstructor
public class ReferralController {

    private final ReferralService referralService;

    @GetMapping("/mine")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<ReferralResponse>> getMyReferralInfo() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ReferralResponse response = referralService.getMyReferralInfo(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Referral info retrieved successfully"));
    }

    @PostMapping("/apply")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<ReferralResponse>> applyReferral(
            @Valid @RequestBody ApplyReferralRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ReferralResponse response = referralService.applyReferralCode(user.getUserId(), request.getCode());
        return ResponseEntity.ok(ApiResponse.success(response, "Referral code applied successfully"));
    }
}
