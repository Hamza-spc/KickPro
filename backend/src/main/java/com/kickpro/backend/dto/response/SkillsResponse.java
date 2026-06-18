package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class SkillsResponse {

    private Long id;
    private Long playerId;
    private Integer dribbling;
    private Integer shooting;
    private Integer passing;
    private Integer speed;
    private Integer heading;
    private Integer stamina;
    private List<String> strengths;
    private List<String> weaknesses;
}
