package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ScoutNoteRequest {

    @NotNull
    @Min(1)
    @Max(5)
    private Integer technicalAbility;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer potential;

    @NotBlank
    private String note;
}
