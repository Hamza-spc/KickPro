package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.Future;
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
    @Future(message = "Match must be scheduled in the future")
    private LocalDateTime dateTime;

    @NotNull(message = "Max players is required")
    @Min(value = 2, message = "At least 2 players are required")
    @Max(value = 22, message = "Maximum 22 players allowed")
    private Integer maxPlayers;
}
