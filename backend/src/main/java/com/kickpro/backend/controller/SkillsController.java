package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.SkillsRequest;
import com.kickpro.backend.dto.response.SkillsResponse;
import com.kickpro.backend.service.SkillsService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/players/skills")
@RequiredArgsConstructor
public class SkillsController {

    private final SkillsService skillsService;

    @PutMapping
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SkillsResponse>> createOrUpdateSkills(
            @Valid @RequestBody SkillsRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SkillsResponse response = skillsService.createOrUpdateSkills(user.getUserId(), request);
        return ResponseEntity.ok(ApiResponse.success(response, "Skills saved successfully"));
    }

    @GetMapping("/me")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<SkillsResponse>> getMySkills() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        SkillsResponse response = skillsService.getMySkills(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(response, "Skills retrieved successfully"));
    }
}
