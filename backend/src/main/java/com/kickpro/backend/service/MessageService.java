package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.SendMessageRequest;
import com.kickpro.backend.dto.response.ConversationSummaryResponse;
import com.kickpro.backend.dto.response.DirectMessageResponse;

import java.util.List;

public interface MessageService {

    List<ConversationSummaryResponse> getConversations(Long userId);

    List<DirectMessageResponse> getMessagesWithUser(Long userId, Long otherUserId);

    DirectMessageResponse sendMessage(Long userId, SendMessageRequest request);
}
