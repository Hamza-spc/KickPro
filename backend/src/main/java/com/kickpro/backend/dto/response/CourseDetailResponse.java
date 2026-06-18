package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.DrillLevel;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
public class CourseDetailResponse {

    private Long id;
    private String title;
    private String description;
    private DrillLevel level;
    private boolean certified;
    private List<LessonSummaryResponse> lessons;
    private LocalDateTime createdAt;

    @Getter
    @Builder
    public static class LessonSummaryResponse {

        private Long id;
        private String title;
        private String content;
        private Integer orderIndex;
        private boolean hasQuiz;
        private boolean finalLesson;
    }
}
