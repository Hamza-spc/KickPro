package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.PostType;
import com.kickpro.backend.entity.TargetSkill;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AdminPostResponse {

    private Long id;
    private Long playerId;
    private String playerName;
    private String title;
    private String cloudinaryUrl;
    private PostType postType;
    private TargetSkill skillTag;
    private boolean flagged;
    private boolean hidden;
    private LocalDateTime uploadedAt;
}
