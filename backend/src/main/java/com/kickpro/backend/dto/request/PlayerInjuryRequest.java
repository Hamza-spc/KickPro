package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerInjuryRequest {

    @NotNull
    private Boolean injured;

    private String injuryType;

    private String injuryBodyPart;

    private String injurySeverity;
}
