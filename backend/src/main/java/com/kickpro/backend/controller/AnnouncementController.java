package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.CreateAnnouncementRequest;
import com.kickpro.backend.dto.response.AnnouncementResponse;
import com.kickpro.backend.service.AnnouncementService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementService announcementService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<AnnouncementResponse>>> getAnnouncements(
            @RequestParam(required = false) String city
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                announcementService.getAnnouncements(user.getUserId(), city),
                "Announcements retrieved successfully"
        ));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT', 'SCOUT')")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> create(
            @Valid @RequestBody CreateAnnouncementRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                announcementService.create(user.getUserId(), request),
                "Announcement created successfully"
        ));
    }

    @PostMapping("/{id}/image")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT', 'SCOUT')")
    public ResponseEntity<ApiResponse<AnnouncementResponse>> uploadImage(
            @PathVariable Long id,
            @RequestPart("file") MultipartFile file
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                announcementService.uploadImage(user.getUserId(), id, file),
                "Announcement image uploaded"
        ));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN', 'AGENT', 'SCOUT')")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable Long id) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        announcementService.delete(user.getUserId(), id);
        return ResponseEntity.ok(ApiResponse.success(null, "Announcement deleted"));
    }
}
