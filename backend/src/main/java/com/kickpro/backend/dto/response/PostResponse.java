package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.PostType;
import com.kickpro.backend.entity.ReactionType;
import com.kickpro.backend.entity.TargetSkill;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.Map;

@Getter
@Builder
public class PostResponse {

    private Long id;
    private Long playerId;
    private String playerName;
    private String playerPhotoUrl;
    private String title;
    private String cloudinaryUrl;
    private PostType postType;
    private TargetSkill skillTag;
    private Integer viewsCount;
    private Double averageRating;
    private LocalDateTime uploadedAt;
    private LocalDateTime updatedAt;
    private boolean ownPost;
    private boolean followingAuthor;
    private long commentCount;
    private Map<ReactionType, Long> reactionCounts;
    private ReactionType myReaction;
}
