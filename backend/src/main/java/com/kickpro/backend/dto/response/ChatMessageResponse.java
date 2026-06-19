package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ChatMessageResponse {

    private Long id;
    private Long roomId;
    private Long matchId;
    private Long senderId;
    private Long senderProfileId;
    private String senderName;
    private String content;
    private LocalDateTime sentAt;
}
