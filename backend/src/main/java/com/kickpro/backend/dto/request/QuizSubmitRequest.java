package com.kickpro.backend.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class QuizSubmitRequest {

    @NotEmpty
    @Valid
    private List<AnswerSubmission> answers;

    @Getter
    @Setter
    public static class AnswerSubmission {

        @NotNull
        private Long questionId;

        @NotNull
        private Integer selectedOptionIndex;
    }
}
