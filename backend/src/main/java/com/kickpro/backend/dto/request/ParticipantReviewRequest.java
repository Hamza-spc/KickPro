package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.ParticipantStatus;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ParticipantReviewRequest {

    @NotNull(message = "Status is required")
    private ParticipantStatus status;
}
