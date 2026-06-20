package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.AnnouncementType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AnnouncementResponse {

    private Long id;
    private String title;
    private String content;
    private AnnouncementType type;
    private String city;
    private String imageUrl;
    private String authorName;
    private String authorRole;
    private boolean official;
    private boolean ownAnnouncement;
    private LocalDateTime createdAt;
}
