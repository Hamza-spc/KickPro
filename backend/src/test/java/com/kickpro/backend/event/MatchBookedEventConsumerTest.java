package com.kickpro.backend.event;

import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.service.NotificationService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
@DisplayName("MatchBookedEventConsumer — Kafka consumer")
class MatchBookedEventConsumerTest {

    @Mock private NotificationService notificationService;
    @Mock private StadiumRepository stadiumRepository;

    @InjectMocks
    private MatchBookedEventConsumer consumer;

    @Test
    @DisplayName("creates MATCH_BOOKED notification for organizer")
    void onMatchBooked_notifiesOrganizer() {
        MatchBookedEvent event = MatchBookedEvent.builder()
                .matchId(12L)
                .stadiumId(5L)
                .organizerId(99L)
                .dateTime(LocalDateTime.of(2026, 7, 10, 18, 0))
                .maxPlayers(10)
                .bookedAt(LocalDateTime.now())
                .build();

        when(stadiumRepository.findById(5L)).thenReturn(Optional.of(
                Stadium.builder().id(5L).name("Agdal Complex").build()));

        consumer.onMatchBooked(event);

        verify(notificationService).notifyUser(
                eq(99L),
                eq("Match booked"),
                eq("Your match at Agdal Complex on 2026-07-10T18:00 is confirmed."),
                eq(NotificationType.MATCH_BOOKED),
                eq("MATCH"),
                eq(12L)
        );
    }

    @Test
    @DisplayName("ignores null or incomplete payloads")
    void onMatchBooked_ignoresInvalidPayload() {
        consumer.onMatchBooked(null);
        consumer.onMatchBooked(MatchBookedEvent.builder().build());

        verifyNoInteractions(notificationService);
    }
}
