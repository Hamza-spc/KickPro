package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;

@Getter
@Builder
public class PlayerSearchResultResponse {

    private Long profileId;
    private String fullName;
    private String city;
    private Position position;
    private PreferredFoot preferredFoot;
    private LocalDate dateOfBirth;
    private String profilePhotoUrl;
    private Double credibilityScore;
    private long certificationCount;
    private long approvedDrillCount;
    private long approvedMatchCount;
    private Double averageDrillScore;
    private SkillsSummary skills;

    @Getter
    @Builder
    public static class SkillsSummary {

        private Integer dribbling;
        private Integer shooting;
        private Integer passing;
        private Integer speed;
        private Integer heading;
        private Integer stamina;
    }
}
