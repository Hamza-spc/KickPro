package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SkillsRequest {

    @NotNull
    @Min(1)
    @Max(10)
    private Integer dribbling;

    @NotNull
    @Min(1)
    @Max(10)
    private Integer shooting;

    @NotNull
    @Min(1)
    @Max(10)
    private Integer passing;

    @NotNull
    @Min(1)
    @Max(10)
    private Integer speed;

    @NotNull
    @Min(1)
    @Max(10)
    private Integer heading;

    @NotNull
    @Min(1)
    @Max(10)
    private Integer stamina;
}
