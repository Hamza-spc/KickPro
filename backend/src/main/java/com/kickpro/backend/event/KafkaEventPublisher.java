package com.kickpro.backend.event;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class KafkaEventPublisher {

    public static final String DRILL_SUBMITTED_TOPIC = "drill.submitted";
    public static final String VIDEO_UPLOADED_TOPIC = "video.uploaded";
    public static final String MATCH_BOOKED_TOPIC = "match.booked";
    public static final String MATCH_COMPLETED_TOPIC = "match.completed";

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public KafkaEventPublisher(@Autowired(required = false) KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishDrillSubmitted(DrillSubmittedEvent event) {
        if (kafkaTemplate == null) {
            log.debug("Kafka unavailable — skipping {}", DRILL_SUBMITTED_TOPIC);
            return;
        }
        kafkaTemplate.send(DRILL_SUBMITTED_TOPIC, event.getSubmissionId().toString(), event);
        log.info("Published {} for submission {}", DRILL_SUBMITTED_TOPIC, event.getSubmissionId());
    }

    public void publishVideoUploaded(VideoUploadedEvent event) {
        if (kafkaTemplate == null) {
            log.debug("Kafka unavailable — skipping {}", VIDEO_UPLOADED_TOPIC);
            return;
        }
        kafkaTemplate.send(VIDEO_UPLOADED_TOPIC, event.getVideoId().toString(), event);
        log.info("Published {} for video {}", VIDEO_UPLOADED_TOPIC, event.getVideoId());
    }

    public void publishMatchBooked(MatchBookedEvent event) {
        if (kafkaTemplate == null) {
            log.debug("Kafka unavailable — skipping {}", MATCH_BOOKED_TOPIC);
            return;
        }
        kafkaTemplate.send(MATCH_BOOKED_TOPIC, event.getMatchId().toString(), event);
        log.info("Published {} for match {}", MATCH_BOOKED_TOPIC, event.getMatchId());
    }

    public void publishMatchCompleted(MatchCompletedEvent event) {
        if (kafkaTemplate == null) {
            log.debug("Kafka unavailable — skipping {}", MATCH_COMPLETED_TOPIC);
            return;
        }
        kafkaTemplate.send(MATCH_COMPLETED_TOPIC, event.getMatchId().toString(), event);
        log.info("Published {} for match {}", MATCH_COMPLETED_TOPIC, event.getMatchId());
    }
}
