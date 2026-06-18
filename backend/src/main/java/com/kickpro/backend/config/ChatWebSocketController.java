package com.kickpro.backend.config;

import com.kickpro.backend.dto.response.ChatMessageResponse;
import com.kickpro.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;
import java.util.Map;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/matches/{matchId}/chat")
    public void sendChatMessage(
            @DestinationVariable Long matchId,
            @Payload Map<String, String> payload,
            Principal principal
    ) {
        if (principal == null) {
            return;
        }

        UserPrincipal user = (UserPrincipal) ((org.springframework.security.authentication.UsernamePasswordAuthenticationToken) principal).getPrincipal();

        String content = payload.get("content");
        if (content == null || content.isBlank()) {
            return;
        }

        com.kickpro.backend.dto.request.ChatMessageRequest request =
                new com.kickpro.backend.dto.request.ChatMessageRequest();
        request.setContent(content);

        ChatMessageResponse response = chatService.sendMessage(user.getUserId(), matchId, request);
        messagingTemplate.convertAndSend("/topic/matches/" + matchId + "/chat", response);
    }
}
