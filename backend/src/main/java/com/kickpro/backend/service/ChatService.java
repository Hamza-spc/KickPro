package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.ChatMessageRequest;
import com.kickpro.backend.dto.response.ChatMessageResponse;

import java.util.List;

public interface ChatService {

    List<ChatMessageResponse> getMessages(Long userId, Long matchId);

    ChatMessageResponse sendMessage(Long userId, Long matchId, ChatMessageRequest request);
}
