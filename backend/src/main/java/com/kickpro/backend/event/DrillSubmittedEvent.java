package com.kickpro.backend.event;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DrillSubmittedEvent {

    private Long submissionId;
    private Long playerId;
    private Long drillId;
    private String videoUrl;
    private LocalDateTime submittedAt;
}
