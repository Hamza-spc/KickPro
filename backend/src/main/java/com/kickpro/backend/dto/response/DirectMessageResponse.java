package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class DirectMessageResponse {

    private Long id;
    private Long senderId;
    private String senderEmail;
    private Long receiverId;
    private String receiverEmail;
    private String content;
    private LocalDateTime createdAt;
    private Boolean ownMessage;
}
