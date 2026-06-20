package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.ScoutNoteRequest;
import com.kickpro.backend.dto.response.ScoutNoteResponse;
import com.kickpro.backend.service.ScoutNoteService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/scouts/notes")
@RequiredArgsConstructor
public class ScoutNoteController {

    private final ScoutNoteService scoutNoteService;

    @GetMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<ScoutNoteResponse>> getNote(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ScoutNoteResponse response = scoutNoteService.getNote(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(response, "Scout note retrieved successfully"));
    }

    @PostMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<ScoutNoteResponse>> createNote(
            @PathVariable Long profileId,
            @Valid @RequestBody ScoutNoteRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ScoutNoteResponse response = scoutNoteService.createNote(user.getUserId(), profileId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Scout note created successfully"));
    }

    @PutMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<ScoutNoteResponse>> updateNote(
            @PathVariable Long profileId,
            @Valid @RequestBody ScoutNoteRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ScoutNoteResponse response = scoutNoteService.updateNote(user.getUserId(), profileId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Scout note updated successfully"));
    }

    @DeleteMapping("/{profileId}")
    @PreAuthorize("hasAnyRole('SCOUT', 'AGENT', 'ADMIN')")
    public ResponseEntity<ApiResponse<Void>> deleteNote(@PathVariable Long profileId) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        scoutNoteService.deleteNote(user.getUserId(), profileId);
        return ResponseEntity.ok(ApiResponse.success(null, "Scout note deleted successfully"));
    }
}
