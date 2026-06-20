package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.MatchGender;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.ParticipantStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Builder
public class MatchResponse {

    private Long id;
    private Long stadiumId;
    private String stadiumName;
    private String stadiumLocation;
    private String stadiumCoverPhotoUrl;
    private Long organizerId;
    private String organizerName;
    private LocalDateTime dateTime;
    private Integer maxPlayers;
    private Integer minAge;
    private Integer maxAge;
    private MatchGender gender;
    private String city;
    private Integer approvedCount;
    private MatchStatus status;
    private Long chatRoomId;
    private List<ParticipantSummary> participants;

    @Getter
    @Builder
    public static class ParticipantSummary {
        private Long id;
        private Long playerId;
        private String playerName;
        private String profilePhotoUrl;
        private ParticipantStatus status;
        private LocalDateTime joinedAt;
    }
}
