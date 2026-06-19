package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.service.PostService;
import com.kickpro.backend.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/players")
@RequiredArgsConstructor
public class FollowController {

    private final PostService postService;

    @PostMapping("/{profileId}/follow")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> follow(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        postService.follow(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(null, "Followed player"));
    }

    @DeleteMapping("/{profileId}/follow")
    @PreAuthorize("hasAnyRole('PLAYER', 'SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> unfollow(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        postService.unfollow(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(null, "Unfollowed player"));
    }
}
