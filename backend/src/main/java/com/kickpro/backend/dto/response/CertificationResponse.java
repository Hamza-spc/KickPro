package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class CertificationResponse {

    private Long id;
    private Long courseId;
    private String courseTitle;
    private String badgeUrl;
    private LocalDateTime earnedAt;
}
