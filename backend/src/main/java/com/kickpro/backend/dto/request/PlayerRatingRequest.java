package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlayerRatingRequest {

    @NotNull(message = "Rated player ID is required")
    private Long ratedPlayerId;

    @NotNull(message = "Performance score is required")
    @Min(1) @Max(5)
    private Integer performanceScore;

    @NotNull(message = "Punctuality score is required")
    @Min(1) @Max(5)
    private Integer punctualityScore;

    @NotNull(message = "Teamwork score is required")
    @Min(1) @Max(5)
    private Integer teamworkScore;

    @NotNull(message = "Behavior score is required")
    @Min(1) @Max(5)
    private Integer behaviorScore;
}
