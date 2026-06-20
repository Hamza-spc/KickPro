package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.SquadJoinRequestStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class SquadJoinRequestResponse {

    private Long id;
    private Long squadId;
    private String squadName;
    private String squadCity;
    private Long playerProfileId;
    private String playerName;
    private String playerPhotoUrl;
    private SquadJoinRequestStatus status;
    private LocalDateTime createdAt;
}
