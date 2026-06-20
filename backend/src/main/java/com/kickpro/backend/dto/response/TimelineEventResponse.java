package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.TimelineEventType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class TimelineEventResponse {

    private TimelineEventType type;
    private String title;
    private String description;
    private LocalDateTime date;
}
