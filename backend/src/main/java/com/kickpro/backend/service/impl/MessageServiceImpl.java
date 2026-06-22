package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.SendMessageRequest;
import com.kickpro.backend.dto.response.ConversationSummaryResponse;
import com.kickpro.backend.dto.response.DirectMessageResponse;
import com.kickpro.backend.entity.DirectMessage;
import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.DirectMessageRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.MessageService;
import com.kickpro.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class MessageServiceImpl implements MessageService {

    private final DirectMessageRepository directMessageRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final NotificationService notificationService;

    @Override
    @Transactional(readOnly = true)
    public List<ConversationSummaryResponse> getConversations(Long userId) {
        Map<Long, DirectMessage> latestByOtherUser = new LinkedHashMap<>();
        for (DirectMessage message : directMessageRepository.findByUserInvolvedOrderByCreatedAtDesc(userId)) {
            Long otherUserId = message.getSender().getId().equals(userId)
                    ? message.getReceiver().getId()
                    : message.getSender().getId();
            latestByOtherUser.putIfAbsent(otherUserId, message);
        }

        List<ConversationSummaryResponse> summaries = new ArrayList<>();
        for (DirectMessage message : latestByOtherUser.values()) {
            User other = message.getSender().getId().equals(userId)
                    ? message.getReceiver()
                    : message.getSender();
            summaries.add(ConversationSummaryResponse.builder()
                    .otherUserId(other.getId())
                    .otherUserName(displayName(other))
                    .otherUserEmail(other.getEmail())
                    .otherUserPhotoUrl(profilePhotoUrl(other))
                    .lastMessage(message.getContent())
                    .lastMessageAt(message.getCreatedAt())
                    .lastMessageOwn(message.getSender().getId().equals(userId))
                    .build());
        }
        return summaries;
    }

    @Override
    @Transactional(readOnly = true)
    public List<DirectMessageResponse> getMessagesWithUser(Long userId, Long otherUserId) {
        if (otherUserId == null) {
            throw new BadRequestException("otherUserId is required");
        }
        if (!userRepository.existsById(otherUserId)) {
            throw new ResourceNotFoundException("User not found");
        }
        return directMessageRepository.findConversation(userId, otherUserId).stream()
                .map(message -> toResponse(message, userId))
                .toList();
    }

    @Override
    @Transactional
    public DirectMessageResponse sendMessage(Long userId, SendMessageRequest request) {
        if (request.getReceiverId() == null) {
            throw new BadRequestException("receiverId is required");
        }
        if (request.getReceiverId().equals(userId)) {
            throw new BadRequestException("Cannot message yourself");
        }
        User sender = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        User receiver = userRepository.findById(request.getReceiverId())
                .orElseThrow(() -> new ResourceNotFoundException("Receiver not found"));

        DirectMessage message = DirectMessage.builder()
                .sender(sender)
                .receiver(receiver)
                .content(request.getContent().trim())
                .build();
        message = directMessageRepository.save(message);
        notificationService.notifyUser(
                receiver.getId(),
                "New message",
                senderDisplayName(sender) + ": " + truncate(message.getContent(), 120),
                NotificationType.DIRECT_MESSAGE,
                "user",
                sender.getId()
        );
        return toResponse(message, userId);
    }

    private String displayName(User user) {
        return playerProfileRepository.findByUserId(user.getId())
                .map(PlayerProfile::getFullName)
                .filter(name -> name != null && !name.isBlank())
                .orElse(user.getEmail());
    }

    private String profilePhotoUrl(User user) {
        return playerProfileRepository.findByUserId(user.getId())
                .map(PlayerProfile::getProfilePhotoUrl)
                .filter(url -> url != null && !url.isBlank())
                .orElse(null);
    }

    private String senderDisplayName(User sender) {
        return displayName(sender);
    }

    private String truncate(String value, int maxLength) {
        if (value == null || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength - 3) + "...";
    }

    private DirectMessageResponse toResponse(DirectMessage message, Long viewerId) {
        return DirectMessageResponse.builder()
                .id(message.getId())
                .senderId(message.getSender().getId())
                .senderEmail(message.getSender().getEmail())
                .receiverId(message.getReceiver().getId())
                .receiverEmail(message.getReceiver().getEmail())
                .content(message.getContent())
                .createdAt(message.getCreatedAt())
                .ownMessage(message.getSender().getId().equals(viewerId))
                .build();
    }
}
