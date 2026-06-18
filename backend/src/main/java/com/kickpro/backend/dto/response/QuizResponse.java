package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class QuizResponse {

    private Long id;
    private Long lessonId;
    private Long courseId;
    private List<QuizQuestionResponse> questions;

    @Getter
    @Builder
    public static class QuizQuestionResponse {

        private Long id;
        private String question;
        private List<String> options;
    }
}
