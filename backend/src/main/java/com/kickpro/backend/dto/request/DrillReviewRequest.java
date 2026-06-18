package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.SubmissionStatus;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DrillReviewRequest {

    @NotNull
    private SubmissionStatus status;

    @Min(0)
    @Max(100)
    private Integer score;
}
