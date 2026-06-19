package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.PlayerProfileRequest;
import com.kickpro.backend.dto.response.PlayerProfileResponse;
import com.kickpro.backend.service.PlayerProfileService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/v1/players/profile")
@RequiredArgsConstructor
public class PlayerProfileController {

    private final PlayerProfileService playerProfileService;

    @PutMapping
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PlayerProfileResponse>> createOrUpdateProfile(
            @Valid @RequestBody PlayerProfileRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerProfileResponse response = playerProfileService.createOrUpdateProfile(user.getUserId(), request);
        return ResponseEntity.ok(ApiResponse.success(response, "Profile saved successfully"));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PlayerProfileResponse>> getMyProfile() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerProfileResponse response = playerProfileService.getMyProfile(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Profile retrieved successfully"));
    }

    @GetMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<PlayerProfileResponse>> getProfileById(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerProfileResponse response = playerProfileService.getProfileById(profileId, user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Profile retrieved successfully"));
    }

    @PostMapping(value = "/photo", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PlayerProfileResponse>> uploadProfilePhoto(
            @RequestPart("file") MultipartFile file
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerProfileResponse response = playerProfileService.uploadProfilePhoto(user.getUserId(), file);
        return ResponseEntity.ok(ApiResponse.success(response, "Profile photo uploaded successfully"));
    }

    @DeleteMapping("/photo")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<PlayerProfileResponse>> deleteProfilePhoto() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        PlayerProfileResponse response = playerProfileService.deleteProfilePhoto(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Profile photo deleted successfully"));
    }
}
