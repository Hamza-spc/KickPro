package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.NotificationType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class NotificationResponse {

    private Long id;
    private String title;
    private String body;
    private NotificationType type;
    private boolean read;
    private String referenceType;
    private Long referenceId;
    private LocalDateTime createdAt;
}
