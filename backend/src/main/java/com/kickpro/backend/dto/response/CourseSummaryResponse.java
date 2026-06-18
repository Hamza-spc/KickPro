package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.DrillLevel;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class CourseSummaryResponse {

    private Long id;
    private String title;
    private String description;
    private DrillLevel level;
    private int lessonCount;
    private boolean certified;
    private LocalDateTime createdAt;
}
