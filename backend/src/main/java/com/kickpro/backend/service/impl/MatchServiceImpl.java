package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateMatchRequest;
import com.kickpro.backend.dto.request.ParticipantReviewRequest;
import com.kickpro.backend.dto.request.PlayerRatingRequest;
import com.kickpro.backend.dto.response.MatchResponse;
import com.kickpro.backend.dto.response.PlayerRatingResponse;
import com.kickpro.backend.entity.ChatRoom;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchParticipant;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.PlayerRating;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.event.KafkaEventPublisher;
import com.kickpro.backend.event.MatchBookedEvent;
import com.kickpro.backend.event.MatchCompletedEvent;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.ChatRoomRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MatchServiceImpl implements MatchService {

    private final MatchRepository matchRepository;
    private final MatchParticipantRepository participantRepository;
    private final StadiumRepository stadiumRepository;
    private final UserRepository userRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final PlayerRatingRepository playerRatingRepository;
    private final KafkaEventPublisher kafkaEventPublisher;

    @Override
    @Transactional
    public MatchResponse createMatch(Long userId, CreateMatchRequest request) {
        PlayerProfile organizer = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before booking matches"));

        User organizerUser = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        matchRepository.lockStadiumForBooking(request.getStadiumId());

        Stadium stadium = stadiumRepository.findById(request.getStadiumId())
                .orElseThrow(() -> new ResourceNotFoundException("Stadium not found"));

        assertNoBookingConflict(request.getStadiumId(), request.getDateTime(), null);

        if (!request.getDateTime().isAfter(LocalDateTime.now().plusMinutes(15))) {
            throw new BadRequestException("Match must be scheduled at least 15 minutes in the future");
        }

        Match match = Match.builder()
                .stadium(stadium)
                .organizer(organizerUser)
                .dateTime(request.getDateTime())
                .maxPlayers(request.getMaxPlayers())
                .status(MatchStatus.OPEN)
                .build();

        Match saved = matchRepository.save(match);

        participantRepository.save(MatchParticipant.builder()
                .match(saved)
                .player(organizer)
                .status(ParticipantStatus.APPROVED)
                .build());

        createChatRoomIfMissing(saved);

        kafkaEventPublisher.publishMatchBooked(MatchBookedEvent.builder()
                .matchId(saved.getId())
                .stadiumId(stadium.getId())
                .organizerId(organizerUser.getId())
                .dateTime(saved.getDateTime())
                .maxPlayers(saved.getMaxPlayers())
                .bookedAt(saved.getCreatedAt())
                .build());

        return toMatchResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public List<MatchResponse> getOpenMatches() {
        return matchRepository.findByStatusOrderByDateTimeAsc(MatchStatus.OPEN).stream()
                .map(this::toMatchResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<MatchResponse> getMyMatches(Long userId) {
        return matchRepository.findMatchesForPlayer(userId).stream()
                .map(this::toMatchResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public MatchResponse getMatchById(Long matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));
        return toMatchResponse(match);
    }

    @Override
    @Transactional
    public MatchResponse requestToJoin(Long userId, Long matchId) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before joining matches"));

        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (match.getStatus() != MatchStatus.OPEN) {
            throw new BadRequestException("This match is not accepting new players");
        }

        if (match.getOrganizer().getId().equals(userId)) {
            throw new BadRequestException("You are already the organizer of this match");
        }

        if (participantRepository.existsByMatchIdAndPlayerId(matchId, player.getId())) {
            throw new BadRequestException("You have already requested to join this match");
        }

        participantRepository.save(MatchParticipant.builder()
                .match(match)
                .player(player)
                .status(ParticipantStatus.PENDING)
                .build());

        return toMatchResponse(matchRepository.findById(matchId).orElseThrow());
    }

    @Override
    @Transactional
    public MatchResponse reviewParticipant(Long organizerUserId, Long matchId, Long participantId,
                                           ParticipantReviewRequest request) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (!match.getOrganizer().getId().equals(organizerUserId)) {
            throw new BadRequestException("Only the organizer can review join requests");
        }

        if (match.getStatus() != MatchStatus.OPEN && match.getStatus() != MatchStatus.FULL) {
            throw new BadRequestException("Cannot review participants for this match");
        }

        if (request.getStatus() != ParticipantStatus.APPROVED
                && request.getStatus() != ParticipantStatus.REJECTED) {
            throw new BadRequestException("Status must be APPROVED or REJECTED");
        }

        MatchParticipant participant = participantRepository.findById(participantId)
                .orElseThrow(() -> new ResourceNotFoundException("Participant not found"));

        if (!participant.getMatch().getId().equals(matchId)) {
            throw new BadRequestException("Participant does not belong to this match");
        }

        if (participant.getStatus() != ParticipantStatus.PENDING) {
            throw new BadRequestException("This join request has already been reviewed");
        }

        if (request.getStatus() == ParticipantStatus.APPROVED) {
            long approvedCount = participantRepository.countByMatchIdAndStatus(
                    matchId, ParticipantStatus.APPROVED);
            if (approvedCount >= match.getMaxPlayers()) {
                throw new BadRequestException("Match is already full");
            }
        }

        participant.setStatus(request.getStatus());
        participantRepository.save(participant);

        if (request.getStatus() == ParticipantStatus.APPROVED) {
            long approvedCount = participantRepository.countByMatchIdAndStatus(
                    matchId, ParticipantStatus.APPROVED);
            if (approvedCount >= match.getMaxPlayers()) {
                match.setStatus(MatchStatus.FULL);
                matchRepository.save(match);
            }
        }

        return toMatchResponse(matchRepository.findById(matchId).orElseThrow());
    }

    @Override
    @Transactional
    public MatchResponse completeMatch(Long organizerUserId, Long matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (!match.getOrganizer().getId().equals(organizerUserId)) {
            throw new BadRequestException("Only the organizer can complete the match");
        }

        if (match.getStatus() == MatchStatus.COMPLETED) {
            throw new BadRequestException("Match is already completed");
        }

        if (match.getStatus() == MatchStatus.CANCELLED) {
            throw new BadRequestException("Cannot complete a cancelled match");
        }

        match.setStatus(MatchStatus.COMPLETED);
        Match saved = matchRepository.save(match);

        kafkaEventPublisher.publishMatchCompleted(MatchCompletedEvent.builder()
                .matchId(saved.getId())
                .organizerId(saved.getOrganizer().getId())
                .completedAt(LocalDateTime.now())
                .build());

        return toMatchResponse(saved);
    }

    @Override
    @Transactional
    public MatchResponse cancelMatch(Long organizerUserId, Long matchId) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (!match.getOrganizer().getId().equals(organizerUserId)) {
            throw new BadRequestException("Only the organizer can cancel the match");
        }

        if (match.getStatus() == MatchStatus.COMPLETED) {
            throw new BadRequestException("Cannot cancel a completed match");
        }

        match.setStatus(MatchStatus.CANCELLED);
        return toMatchResponse(matchRepository.save(match));
    }

    @Override
    @Transactional
    public PlayerRatingResponse submitRating(Long userId, Long matchId, PlayerRatingRequest request) {
        Match match = matchRepository.findById(matchId)
                .orElseThrow(() -> new ResourceNotFoundException("Match not found"));

        if (match.getStatus() != MatchStatus.COMPLETED) {
            throw new BadRequestException("Ratings are only available after the match is completed");
        }

        PlayerProfile rater = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Player profile not found"));

        PlayerProfile ratedPlayer = playerProfileRepository.findById(request.getRatedPlayerId())
                .orElseThrow(() -> new ResourceNotFoundException("Rated player not found"));

        if (rater.getId().equals(ratedPlayer.getId())) {
            throw new BadRequestException("You cannot rate yourself");
        }

        if (!isApprovedParticipant(matchId, rater.getId())) {
            throw new BadRequestException("Only approved participants can submit ratings");
        }

        if (!isApprovedParticipant(matchId, ratedPlayer.getId())) {
            throw new BadRequestException("You can only rate approved participants");
        }

        if (playerRatingRepository.existsByMatchIdAndRaterIdAndRatedPlayerId(
                matchId, rater.getId(), ratedPlayer.getId())) {
            throw new BadRequestException("You have already rated this player for this match");
        }

        PlayerRating rating = PlayerRating.builder()
                .match(match)
                .rater(rater)
                .ratedPlayer(ratedPlayer)
                .performanceScore(request.getPerformanceScore())
                .punctualityScore(request.getPunctualityScore())
                .teamworkScore(request.getTeamworkScore())
                .behaviorScore(request.getBehaviorScore())
                .build();

        return toRatingResponse(playerRatingRepository.save(rating));
    }

    @Override
    @Transactional(readOnly = true)
    public List<PlayerRatingResponse> getMatchRatings(Long matchId) {
        if (!matchRepository.existsById(matchId)) {
            throw new ResourceNotFoundException("Match not found");
        }
        return playerRatingRepository.findByMatchId(matchId).stream()
                .map(this::toRatingResponse)
                .toList();
    }

    private void assertNoBookingConflict(Long stadiumId, LocalDateTime dateTime, Long excludeMatchId) {
        LocalDateTime slotStart = dateTime.minusMinutes(Match.DEFAULT_DURATION_MINUTES);
        LocalDateTime slotEnd = dateTime.plusMinutes(Match.DEFAULT_DURATION_MINUTES);

        List<Match> conflicts = matchRepository.findOverlappingMatches(stadiumId, slotStart, slotEnd);
        boolean hasConflict = conflicts.stream()
                .anyMatch(m -> excludeMatchId == null || !m.getId().equals(excludeMatchId));

        if (hasConflict) {
            throw new BadRequestException("This stadium is already booked for the selected time slot");
        }
    }

    private void createChatRoomIfMissing(Match match) {
        if (chatRoomRepository.findByMatchId(match.getId()).isPresent()) {
            return;
        }
        chatRoomRepository.save(ChatRoom.builder().match(match).build());
    }

    private boolean isApprovedParticipant(Long matchId, Long playerId) {
        return participantRepository.findByMatchIdAndPlayerId(matchId, playerId)
                .map(p -> p.getStatus() == ParticipantStatus.APPROVED)
                .orElse(false);
    }

    private MatchResponse toMatchResponse(Match match) {
        List<MatchParticipant> participants = participantRepository
                .findByMatchIdOrderByJoinedAtAsc(match.getId());

        long approvedCount = participants.stream()
                .filter(p -> p.getStatus() == ParticipantStatus.APPROVED)
                .count();

        Long chatRoomId = chatRoomRepository.findByMatchId(match.getId())
                .map(ChatRoom::getId)
                .orElse(null);

        List<MatchResponse.ParticipantSummary> participantSummaries = participants.stream()
                .map(p -> MatchResponse.ParticipantSummary.builder()
                        .id(p.getId())
                        .playerId(p.getPlayer().getId())
                        .playerName(p.getPlayer().getFullName())
                        .profilePhotoUrl(p.getPlayer().getProfilePhotoUrl())
                        .status(p.getStatus())
                        .joinedAt(p.getJoinedAt())
                        .build())
                .toList();

        return MatchResponse.builder()
                .id(match.getId())
                .stadiumId(match.getStadium().getId())
                .stadiumName(match.getStadium().getName())
                .stadiumLocation(match.getStadium().getLocation())
                .organizerId(match.getOrganizer().getId())
                .organizerName(resolveOrganizerName(match))
                .dateTime(match.getDateTime())
                .maxPlayers(match.getMaxPlayers())
                .approvedCount((int) approvedCount)
                .status(match.getStatus())
                .chatRoomId(chatRoomId)
                .participants(participantSummaries)
                .build();
    }

    private String resolveOrganizerName(Match match) {
        return playerProfileRepository.findByUserId(match.getOrganizer().getId())
                .map(PlayerProfile::getFullName)
                .orElse(match.getOrganizer().getEmail());
    }

    private PlayerRatingResponse toRatingResponse(PlayerRating rating) {
        return PlayerRatingResponse.builder()
                .id(rating.getId())
                .matchId(rating.getMatch().getId())
                .raterId(rating.getRater().getId())
                .raterName(rating.getRater().getFullName())
                .ratedPlayerId(rating.getRatedPlayer().getId())
                .ratedPlayerName(rating.getRatedPlayer().getFullName())
                .performanceScore(rating.getPerformanceScore())
                .punctualityScore(rating.getPunctualityScore())
                .teamworkScore(rating.getTeamworkScore())
                .behaviorScore(rating.getBehaviorScore())
                .ratedAt(rating.getRatedAt())
                .build();
    }
}
