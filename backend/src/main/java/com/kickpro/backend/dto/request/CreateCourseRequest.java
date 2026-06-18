package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.DrillLevel;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
public class CreateCourseRequest {

    @NotBlank
    @Size(max = 200)
    private String title;

    @NotBlank
    @Size(max = 2000)
    private String description;

    @NotNull
    private DrillLevel level;

    @NotEmpty
    @Valid
    private List<CreateLessonRequest> lessons;

    @Getter
    @Setter
    public static class CreateLessonRequest {

        @NotBlank
        @Size(max = 200)
        private String title;

        @NotBlank
        @Size(max = 5000)
        private String content;

        @NotNull
        private Integer orderIndex;

        @Valid
        private CreateQuizRequest quiz;
    }

    @Getter
    @Setter
    public static class CreateQuizRequest {

        @NotEmpty
        @Valid
        private List<CreateQuizQuestionRequest> questions;
    }

    @Getter
    @Setter
    public static class CreateQuizQuestionRequest {

        @NotBlank
        @Size(max = 1000)
        private String question;

        @NotEmpty
        @Size(min = 2, max = 6)
        private List<@NotBlank @Size(max = 500) String> options;

        @NotNull
        private Integer correctAnswerIndex;
    }
}
