package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.NotificationResponse;
import com.kickpro.backend.entity.NotificationType;

import java.util.List;

public interface NotificationService {

    void notifyUser(Long userId, String title, String body, NotificationType type, String referenceType, Long referenceId);

    List<NotificationResponse> getNotifications(Long userId);

    long getUnreadCount(Long userId);

    void markAllRead(Long userId);

    void registerDeviceToken(Long userId, String token, String platform);
}
