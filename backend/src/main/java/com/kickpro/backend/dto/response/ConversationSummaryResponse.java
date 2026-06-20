package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ConversationSummaryResponse {

    private Long otherUserId;
    private String otherUserName;
    private String otherUserEmail;
    private String lastMessage;
    private LocalDateTime lastMessageAt;
    private Boolean lastMessageOwn;
}
