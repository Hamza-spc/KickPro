package com.kickpro.backend.event;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class MatchBookedEvent {

    private Long matchId;
    private Long stadiumId;
    private Long organizerId;
    private LocalDateTime dateTime;
    private Integer maxPlayers;
    private LocalDateTime bookedAt;
}
