package com.kickpro.backend.controller;

import com.kickpro.backend.config.UserPrincipal;
import com.kickpro.backend.dto.ApiResponse;
import com.kickpro.backend.dto.request.SendMessageRequest;
import com.kickpro.backend.dto.response.ConversationSummaryResponse;
import com.kickpro.backend.dto.response.DirectMessageResponse;
import com.kickpro.backend.service.MessageService;
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
@RequestMapping("/api/v1/messages")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @GetMapping("/conversations")
    @PreAuthorize("hasAnyRole('AGENT', 'SCOUT', 'PLAYER', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<ConversationSummaryResponse>>> getConversations() {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<ConversationSummaryResponse> conversations = messageService.getConversations(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(conversations, "Conversations retrieved successfully"));
    }

    @GetMapping("/with/{otherUserId}")
    @PreAuthorize("hasAnyRole('AGENT', 'SCOUT', 'PLAYER', 'ADMIN')")
    public ResponseEntity<ApiResponse<List<DirectMessageResponse>>> getMessagesWithUser(
            @PathVariable Long otherUserId
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        List<DirectMessageResponse> messages = messageService.getMessagesWithUser(user.getUserId(), otherUserId);
        return ResponseEntity.ok(ApiResponse.success(messages, "Messages retrieved successfully"));
    }

    @PostMapping("/send")
    @PreAuthorize("hasAnyRole('AGENT', 'SCOUT', 'PLAYER', 'ADMIN')")
    public ResponseEntity<ApiResponse<DirectMessageResponse>> sendMessage(
            @Valid @RequestBody SendMessageRequest request
    ) {
        UserPrincipal user = SecurityUtils.getCurrentUser();
        DirectMessageResponse response = messageService.sendMessage(user.getUserId(), request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Message sent successfully"));
    }
}
