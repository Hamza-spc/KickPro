package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RecoveryPlanRequest {

    @NotBlank
    private String injuryType;

    @NotBlank
    private String bodyPart;

    @NotBlank
    private String severity;
}
