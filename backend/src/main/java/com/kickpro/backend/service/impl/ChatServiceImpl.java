package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.ChatMessageRequest;
import com.kickpro.backend.dto.response.ChatMessageResponse;
import com.kickpro.backend.entity.ChatMessage;
import com.kickpro.backend.entity.ChatRoom;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.ChatMessageRepository;
import com.kickpro.backend.repository.ChatRoomRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatServiceImpl implements ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final MatchRepository matchRepository;
    private final MatchParticipantRepository participantRepository;
    private final PlayerProfileRepository playerProfileRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ChatMessageResponse> getMessages(Long userId, Long matchId) {
        ChatRoom room = getAccessibleChatRoom(userId, matchId);
        return chatMessageRepository.findByRoomIdOrderBySentAtAsc(room.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public ChatMessageResponse sendMessage(Long userId, Long matchId, ChatMessageRequest request) {
        ChatRoom room = getAccessibleChatRoom(userId, matchId);

        ChatMessage message = ChatMessage.builder()
                .room(room)
                .senderId(userId)
                .content(request.getContent().trim())
                .build();

        return toResponse(chatMessageRepository.save(message));
    }

    private ChatRoom getAccessibleChatRoom(Long userId, Long matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (match.getStatus() == MatchStatus.CANCELLED) {
            throw new BadRequestException("Chat is not available for cancelled matches");
        }

        ChatRoom room = chatRoomRepository.findByMatchId(matchId)
                .orElseThrow(() -> new BadRequestException("Chat room not found for this match"));

        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Player profile not found"));

        boolean isApproved = participantRepository.findByMatchIdAndPlayerId(matchId, player.getId())
                .map(p -> p.getStatus() == ParticipantStatus.APPROVED)
                .orElse(false);

        if (!isApproved) {
            throw new BadRequestException("Only approved participants can access the chat");
        }

        return room;
    }

    private ChatMessageResponse toResponse(ChatMessage message) {
        String senderName = playerProfileRepository.findByUserId(message.getSenderId())
                .map(PlayerProfile::getFullName)
                .orElse("Player");

        return ChatMessageResponse.builder()
                .id(message.getId())
                .roomId(message.getRoom().getId())
                .matchId(message.getRoom().getMatch().getId())
                .senderId(message.getSenderId())
                .senderName(senderName)
                .content(message.getContent())
                .sentAt(message.getSentAt())
                .build();
    }
}
