package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.RegisterDeviceTokenRequest;
import com.kickpro.backend.dto.response.NotificationResponse;
import com.kickpro.backend.service.NotificationService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<List<NotificationResponse>>> getNotifications() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        return ResponseEntity.ok(ApiResponse.success(
                notificationService.getNotifications(user.getUserId()),
                "Notifications retrieved successfully"
        ));
    }

    @GetMapping("/unread-count")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadCount() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        long count = notificationService.getUnreadCount(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(Map.of("count", count), "Unread count retrieved"));
    }

    @PutMapping("/read-all")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Void>> markAllRead() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        notificationService.markAllRead(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(null, "All notifications marked as read"));
    }

    @PostMapping("/device-token")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<ApiResponse<Void>> registerDeviceToken(
            @Valid @RequestBody RegisterDeviceTokenRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        notificationService.registerDeviceToken(user.getUserId(), request.getToken(), request.getPlatform());
        return ResponseEntity.ok(ApiResponse.success(null, "Device token registered"));
    }
}
