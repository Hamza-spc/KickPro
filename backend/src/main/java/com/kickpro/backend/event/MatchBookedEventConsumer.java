package com.kickpro.backend.event;

import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.Stadium;
import com.kickpro.backend.repository.StadiumRepository;
import com.kickpro.backend.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@Profile("!test")
@RequiredArgsConstructor
public class MatchBookedEventConsumer {

    private final NotificationService notificationService;
    private final StadiumRepository stadiumRepository;

    @KafkaListener(
            topics = KafkaEventPublisher.MATCH_BOOKED_TOPIC,
            groupId = "${spring.kafka.consumer.group-id}"
    )
    public void onMatchBooked(MatchBookedEvent event) {
        if (event == null || event.getMatchId() == null || event.getOrganizerId() == null) {
            log.warn("Ignoring invalid match.booked payload: {}", event);
            return;
        }

        String stadiumLabel = stadiumRepository.findById(event.getStadiumId())
                .map(Stadium::getName)
                .orElse("stadium #" + event.getStadiumId());

        log.info("Consumed {} for match {} (organizer {})",
                KafkaEventPublisher.MATCH_BOOKED_TOPIC, event.getMatchId(), event.getOrganizerId());

        notificationService.notifyUser(
                event.getOrganizerId(),
                "Match booked",
                "Your match at " + stadiumLabel + " on " + event.getDateTime() + " is confirmed.",
                NotificationType.MATCH_BOOKED,
                "MATCH",
                event.getMatchId()
        );
    }
}
