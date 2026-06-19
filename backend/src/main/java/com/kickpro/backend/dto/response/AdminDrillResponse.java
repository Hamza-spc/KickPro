package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.TargetSkill;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AdminDrillResponse {

    private Long id;
    private String title;
    private String description;
    private String rules;
    private DrillLevel level;
    private Integer progressionOrder;
    private Long parentDrillId;
    private TargetSkill targetSkill;
}
