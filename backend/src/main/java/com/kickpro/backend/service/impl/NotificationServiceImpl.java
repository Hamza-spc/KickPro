package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.NotificationResponse;
import com.kickpro.backend.entity.AppNotification;
import com.kickpro.backend.entity.DeviceToken;
import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.AppNotificationRepository;
import com.kickpro.backend.repository.DeviceTokenRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final AppNotificationRepository appNotificationRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public void notifyUser(Long userId, String title, String body, NotificationType type,
                           String referenceType, Long referenceId) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null) {
            return;
        }
        appNotificationRepository.save(AppNotification.builder()
                .user(user)
                .title(title)
                .body(body)
                .type(type)
                .referenceType(referenceType)
                .referenceId(referenceId)
                .read(false)
                .build());
    }

    @Override
    @Transactional(readOnly = true)
    public List<NotificationResponse> getNotifications(Long userId) {
        return appNotificationRepository.findByUser_IdOrderByCreatedAtDesc(userId).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public long getUnreadCount(Long userId) {
        return appNotificationRepository.countByUser_IdAndReadFalse(userId);
    }

    @Override
    @Transactional
    public void markAllRead(Long userId) {
        appNotificationRepository.markAllRead(userId);
    }

    @Override
    @Transactional
    public void registerDeviceToken(Long userId, String token, String platform) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (deviceTokenRepository.findByUser_IdAndToken(userId, token).isPresent()) {
            return;
        }
        deviceTokenRepository.save(DeviceToken.builder()
                .user(user)
                .token(token)
                .platform(platform)
                .build());
    }

    private NotificationResponse toResponse(AppNotification notification) {
        return NotificationResponse.builder()
                .id(notification.getId())
                .title(notification.getTitle())
                .body(notification.getBody())
                .type(notification.getType())
                .read(Boolean.TRUE.equals(notification.getRead()))
                .referenceType(notification.getReferenceType())
                .referenceId(notification.getReferenceId())
                .createdAt(notification.getCreatedAt())
                .build();
    }
}
