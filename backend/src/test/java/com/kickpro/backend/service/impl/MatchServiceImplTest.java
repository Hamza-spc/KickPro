package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateMatchRequest;
import com.kickpro.backend.dto.request.ParticipantReviewRequest;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchGender;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.event.KafkaEventPublisher;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.ChatRoomRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.CredibilityService;
import com.kickpro.backend.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@DisplayName("MatchService — booking and participation")
class MatchServiceImplTest {

    @Mock private MatchRepository matchRepository;
    @Mock private MatchParticipantRepository participantRepository;
    @Mock private StadiumRepository stadiumRepository;
    @Mock private UserRepository userRepository;
    @Mock private PlayerProfileRepository playerProfileRepository;
    @Mock private ChatRoomRepository chatRoomRepository;
    @Mock private PlayerRatingRepository playerRatingRepository;
    @Mock private KafkaEventPublisher kafkaEventPublisher;
    @Mock private CredibilityService credibilityService;
    @Mock private NotificationService notificationService;

    @InjectMocks
    private MatchServiceImpl matchService;

    private User organizerUser;
    private PlayerProfile organizerProfile;
    private Stadium stadium;
    private CreateMatchRequest validRequest;

    @BeforeEach
    void setUp() {
        organizerUser = User.builder().id(1L).email("org@kickpro.dev").build();
        organizerProfile = PlayerProfile.builder()
                .id(10L)
                .user(organizerUser)
                .fullName("Organizer")
                .dateOfBirth(LocalDate.of(2000, 1, 1))
                .city("Rabat")
                .build();

        stadium = Stadium.builder()
                .id(5L)
                .name("Agdal Complex")
                .location("Agdal")
                .city("Rabat")
                .pricePerHour(BigDecimal.valueOf(300))
                .openTime(LocalTime.of(8, 0))
                .closeTime(LocalTime.of(23, 0))
                .photos(List.of())
                .build();

        validRequest = new CreateMatchRequest();
        validRequest.setStadiumId(5L);
        validRequest.setDateTime(LocalDateTime.now().plusDays(2).withHour(18).withMinute(0));
        validRequest.setMaxPlayers(10);
        validRequest.setMinAge(18);
        validRequest.setMaxAge(35);
        validRequest.setGender(MatchGender.MIXED);
    }

    @Test
    @DisplayName("createMatch persists match and publishes Kafka event")
    void createMatch_success() {
        Match saved = Match.builder()
                .id(99L)
                .stadium(stadium)
                .organizer(organizerUser)
                .dateTime(validRequest.getDateTime())
                .maxPlayers(10)
                .minAge(18)
                .maxAge(35)
                .gender(MatchGender.MIXED)
                .city("Rabat")
                .status(MatchStatus.OPEN)
                .createdAt(LocalDateTime.now())
                .build();

        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));
        when(userRepository.findById(1L)).thenReturn(Optional.of(organizerUser));
        when(stadiumRepository.findById(5L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findOverlappingMatches(eq(5L), any(), any())).thenReturn(List.of());
        when(matchRepository.save(any(Match.class))).thenReturn(saved);
        when(participantRepository.findByMatchIdOrderByJoinedAtAsc(99L)).thenReturn(List.of());
        when(chatRoomRepository.findByMatchId(99L)).thenReturn(Optional.empty());
        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));

        var response = matchService.createMatch(1L, validRequest);

        assertEquals(99L, response.getId());
        assertEquals("Rabat", response.getCity());
        verify(kafkaEventPublisher).publishMatchBooked(any());
        verify(chatRoomRepository).save(any());
    }

    @Test
    @DisplayName("createMatch rejects when player profile is missing")
    void createMatch_throwsWhenNoProfile() {
        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.empty());

        assertThrows(BadRequestException.class, () -> matchService.createMatch(1L, validRequest));
        verify(matchRepository, never()).save(any());
    }

    @Test
    @DisplayName("createMatch rejects overlapping stadium slot")
    void createMatch_throwsOnBookingConflict() {
        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));
        when(userRepository.findById(1L)).thenReturn(Optional.of(organizerUser));
        when(stadiumRepository.findById(5L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findOverlappingMatches(eq(5L), any(), any()))
                .thenReturn(List.of(Match.builder().id(1L).build()));

        BadRequestException ex = assertThrows(
                BadRequestException.class,
                () -> matchService.createMatch(1L, validRequest));
        assertEquals("This stadium is already booked for the selected time slot", ex.getMessage());
    }

    @Test
    @DisplayName("createMatch rejects schedule less than 15 minutes ahead")
    void createMatch_throwsWhenScheduledTooSoon() {
        validRequest.setDateTime(LocalDateTime.now().plusMinutes(5));

        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));
        when(userRepository.findById(1L)).thenReturn(Optional.of(organizerUser));
        when(stadiumRepository.findById(5L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findOverlappingMatches(eq(5L), any(), any())).thenReturn(List.of());

        assertThrows(BadRequestException.class, () -> matchService.createMatch(1L, validRequest));
    }

    @Test
    @DisplayName("createMatch rejects min age greater than max age")
    void createMatch_throwsWhenAgeRangeInvalid() {
        validRequest.setMinAge(40);
        validRequest.setMaxAge(20);

        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));
        when(userRepository.findById(1L)).thenReturn(Optional.of(organizerUser));
        when(stadiumRepository.findById(5L)).thenReturn(Optional.of(stadium));
        when(matchRepository.findOverlappingMatches(eq(5L), any(), any())).thenReturn(List.of());

        assertThrows(BadRequestException.class, () -> matchService.createMatch(1L, validRequest));
    }

    @Test
    @DisplayName("getMatchById throws when match does not exist")
    void getMatchById_throwsWhenNotFound() {
        when(matchRepository.findById(404L)).thenReturn(Optional.empty());

        assertThrows(ResourceNotFoundException.class, () -> matchService.getMatchById(404L));
    }

    @Test
    @DisplayName("requestToJoin rejects closed matches")
    void requestToJoin_throwsWhenMatchNotOpen() {
        User organizer = User.builder().id(2L).email("o@kickpro.dev").build();
        Match match = Match.builder()
                .id(7L)
                .organizer(organizer)
                .status(MatchStatus.COMPLETED)
                .stadium(stadium)
                .build();
        PlayerProfile joiner = PlayerProfile.builder()
                .id(20L)
                .user(User.builder().id(3L).build())
                .fullName("Joiner")
                .build();

        when(playerProfileRepository.findByUserId(3L)).thenReturn(Optional.of(joiner));
        when(matchRepository.findById(7L)).thenReturn(Optional.of(match));

        assertThrows(BadRequestException.class, () -> matchService.requestToJoin(3L, 7L));
    }

    @Test
    @DisplayName("requestToJoin rejects organizer self-join")
    void requestToJoin_throwsWhenOrganizerJoins() {
        Match match = Match.builder()
                .id(7L)
                .organizer(organizerUser)
                .status(MatchStatus.OPEN)
                .stadium(stadium)
                .build();

        when(playerProfileRepository.findByUserId(1L)).thenReturn(Optional.of(organizerProfile));
        when(matchRepository.findById(7L)).thenReturn(Optional.of(match));

        assertThrows(BadRequestException.class, () -> matchService.requestToJoin(1L, 7L));
    }

    @Test
    @DisplayName("requestToJoin rejects injured players")
    void requestToJoin_throwsWhenPlayerInjured() {
        User otherOrganizer = User.builder().id(2L).build();
        Match match = Match.builder()
                .id(7L)
                .organizer(otherOrganizer)
                .status(MatchStatus.OPEN)
                .stadium(stadium)
                .build();
        PlayerProfile injured = PlayerProfile.builder()
                .id(21L)
                .user(User.builder().id(3L).build())
                .fullName("Injured")
                .injured(true)
                .build();

        when(playerProfileRepository.findByUserId(3L)).thenReturn(Optional.of(injured));
        when(matchRepository.findById(7L)).thenReturn(Optional.of(match));

        assertThrows(BadRequestException.class, () -> matchService.requestToJoin(3L, 7L));
    }

    @Test
    @DisplayName("reviewParticipant rejects non-organizer")
    void reviewParticipant_throwsWhenNotOrganizer() {
        Match match = Match.builder()
                .id(8L)
                .organizer(User.builder().id(99L).build())
                .status(MatchStatus.OPEN)
                .stadium(stadium)
                .build();

        when(matchRepository.findById(8L)).thenReturn(Optional.of(match));

        ParticipantReviewRequest review = new ParticipantReviewRequest();
        review.setStatus(ParticipantStatus.APPROVED);

        assertThrows(BadRequestException.class,
                () -> matchService.reviewParticipant(1L, 8L, 50L, review));
    }

    @Test
    @DisplayName("completeMatch rejects non-organizer")
    void completeMatch_throwsWhenNotOrganizer() {
        Match match = Match.builder()
                .id(9L)
                .organizer(User.builder().id(99L).build())
                .status(MatchStatus.OPEN)
                .stadium(stadium)
                .build();

        when(matchRepository.findById(9L)).thenReturn(Optional.of(match));

        assertThrows(BadRequestException.class, () -> matchService.completeMatch(1L, 9L));
    }
}
