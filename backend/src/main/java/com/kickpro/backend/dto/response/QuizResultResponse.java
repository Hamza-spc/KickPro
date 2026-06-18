package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class QuizResultResponse {

    private boolean passed;
    private int scorePercent;
    private int correctCount;
    private int totalQuestions;
    private boolean certificationEarned;
    private CertificationResponse certification;
}
