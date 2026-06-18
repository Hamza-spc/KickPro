package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.ChatMessageRequest;
import com.kickpro.backend.dto.response.ChatMessageResponse;
import com.kickpro.backend.service.ChatService;
import com.kickpro.backend.util.SecurityUtils;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/matches/{matchId}/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    @GetMapping("/messages")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<List<ChatMessageResponse>>> getMessages(
            @PathVariable Long matchId
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<ChatMessageResponse> messages = chatService.getMessages(user.getUserId(), matchId);
        return ResponseEntity.ok(ApiResponse.success(messages, "Chat messages retrieved successfully"));
    }

    @PostMapping("/messages")
    @PreAuthorize("hasRole('PLAYER')")
    public ResponseEntity<ApiResponse<ChatMessageResponse>> sendMessage(
            @PathVariable Long matchId,
            @Valid @RequestBody ChatMessageRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        ChatMessageResponse response = chatService.sendMessage(user.getUserId(), matchId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Message sent successfully"));
    }
}
