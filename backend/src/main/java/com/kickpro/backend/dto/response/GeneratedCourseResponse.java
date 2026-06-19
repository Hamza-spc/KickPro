package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.DrillLevel;
import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class GeneratedCourseResponse {

    private String title;
    private String description;
    private DrillLevel level;
    private List<GeneratedLessonResponse> lessons;

    @Getter
    @Builder
    public static class GeneratedLessonResponse {
        private String title;
        private String content;
        private Integer orderIndex;
        private GeneratedQuizResponse quiz;
    }

    @Getter
    @Builder
    public static class GeneratedQuizResponse {
        private List<GeneratedQuestionResponse> questions;
    }

    @Getter
    @Builder
    public static class GeneratedQuestionResponse {
        private String question;
        private List<String> options;
        private Integer correctAnswerIndex;
    }
}
