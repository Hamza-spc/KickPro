package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class DrillRecommendationResponse {

    private List<Recommendation> recommendations;
    private String summary;

    @Getter
    @Builder
    public static class Recommendation {
        private Long drillId;
        private String drillTitle;
        private String targetSkill;
        private String level;
        private String reason;
    }
}
