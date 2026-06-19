package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class CommentResponse {

    private Long id;
    private Long authorId;
    private Long authorProfileId;
    private String authorName;
    private String text;
    private LocalDateTime createdAt;
}
