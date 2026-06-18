package com.kickpro.backend.event;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class MatchCompletedEvent {

    private Long matchId;
    private Long organizerId;
    private LocalDateTime completedAt;
}
