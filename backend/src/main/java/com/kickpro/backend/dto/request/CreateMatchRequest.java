package com.kickpro.backend.dto.request;

import com.kickpro.backend.entity.MatchGender;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class CreateMatchRequest {

    @NotNull(message = "Stadium ID is required")
    private Long stadiumId;

    @NotNull(message = "Match date and time is required")
    private LocalDateTime dateTime;

    @NotNull(message = "Max players is required")
    @Min(value = 2, message = "At least 2 players are required")
    @Max(value = 22, message = "Maximum 22 players allowed")
    private Integer maxPlayers;

    @NotNull(message = "Minimum age is required")
    @Min(value = 13, message = "Minimum age must be at least 13")
    @Max(value = 80, message = "Minimum age must be at most 80")
    private Integer minAge;

    @NotNull(message = "Maximum age is required")
    @Min(value = 13, message = "Maximum age must be at least 13")
    @Max(value = 80, message = "Maximum age must be at most 80")
    private Integer maxAge;

    @NotNull(message = "Gender restriction is required")
    private MatchGender gender;
}
