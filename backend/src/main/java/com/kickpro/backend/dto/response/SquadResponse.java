package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
public class SquadResponse {

    private Long id;
    private String name;
    private String city;
    private Long captainId;
    private String captainName;
    private String captainPhotoUrl;
    private boolean ownSquad;
    private int memberCount;
    private List<MemberSummary> members;
    private LocalDateTime createdAt;

    @Getter
    @Builder
    public static class MemberSummary {
        private Long id;
        private Long playerId;
        private String playerName;
        private String profilePhotoUrl;
        private LocalDateTime joinedAt;
    }
}
