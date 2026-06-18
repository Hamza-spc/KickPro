package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.BadgeType;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class BadgeResponse {

    private Long id;
    private Long playerId;
    private Long drillId;
    private String drillTitle;
    private LocalDateTime earnedAt;
    private BadgeType badgeType;
}
