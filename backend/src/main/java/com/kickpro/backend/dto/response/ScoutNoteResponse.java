package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ScoutNoteResponse {

    private Long id;
    private Long playerProfileId;
    private Long scoutUserId;
    private String scoutName;
    private String scoutEmail;
    private Integer technicalAbility;
    private Integer potential;
    private String note;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
