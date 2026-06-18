package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.BadgeType;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.TargetSkill;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class VideoResponse {

    private Long id;
    private Long playerId;
    private String playerName;
    private String title;
    private String cloudinaryUrl;
    private TargetSkill skillTag;
    private Integer viewsCount;
    private Double averageRating;
    private LocalDateTime uploadedAt;
}
