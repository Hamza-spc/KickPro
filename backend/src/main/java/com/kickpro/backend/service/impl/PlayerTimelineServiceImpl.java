package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.TimelineEventResponse;
import com.kickpro.backend.entity.Certification;
import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.entity.MatchParticipant;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.TimelineEventType;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.PlayerTimelineService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlayerTimelineServiceImpl implements PlayerTimelineService {

    private final PlayerProfileRepository playerProfileRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final MatchParticipantRepository matchParticipantRepository;
    private final CertificationRepository certificationRepository;
    private final VideoRepository videoRepository;

    @Override
    @Transactional(readOnly = true)
    public List<TimelineEventResponse> getTimeline(Long profileId) {
        if (!playerProfileRepository.existsById(profileId)) {
            throw new ResourceNotFoundException("Player profile not found");
        }

        List<TimelineEventResponse> events = new ArrayList<>();

        for (DrillSubmission submission : drillSubmissionRepository.findByPlayerId(profileId)) {
            if (submission.getStatus() != SubmissionStatus.APPROVED) {
                continue;
            }
            LocalDateTime date = submission.getReviewedAt() != null
                    ? submission.getReviewedAt()
                    : submission.getSubmittedAt();
            String drillTitle = submission.getDrill() != null ? submission.getDrill().getTitle() : "Drill";
            events.add(TimelineEventResponse.builder()
                    .type(TimelineEventType.DRILL_APPROVED)
                    .title("Drill approved: " + drillTitle)
                    .description(submission.getScore() != null
                            ? "Score: " + submission.getScore() + "/100"
                            : "Drill submission approved")
                    .date(date)
                    .build());
        }

        for (MatchParticipant participant : matchParticipantRepository.findByPlayerIdOrderByJoinedAtDesc(profileId)) {
            if (participant.getStatus() != ParticipantStatus.APPROVED) {
                continue;
            }
            String stadiumName = participant.getMatch().getStadium() != null
                    ? participant.getMatch().getStadium().getName()
                    : "Match";
            events.add(TimelineEventResponse.builder()
                    .type(TimelineEventType.MATCH_PARTICIPATION)
                    .title("Match participation")
                    .description("Played at " + stadiumName)
                    .date(participant.getJoinedAt())
                    .build());
        }

        for (Certification certification : certificationRepository.findByPlayerIdOrderByEarnedAtDesc(profileId)) {
            events.add(TimelineEventResponse.builder()
                    .type(TimelineEventType.CERTIFICATION)
                    .title("Certification earned")
                    .description(certification.getCourse().getTitle())
                    .date(certification.getEarnedAt())
                    .build());
        }

        for (Video video : videoRepository.findByPlayerIdOrderByUploadedAtDesc(profileId)) {
            if (Boolean.TRUE.equals(video.getHidden())) {
                continue;
            }
            events.add(TimelineEventResponse.builder()
                    .type(TimelineEventType.POST)
                    .title("Post shared")
                    .description(video.getTitle())
                    .date(video.getUploadedAt())
                    .build());
        }

        events.sort(Comparator.comparing(TimelineEventResponse::getDate).reversed());
        return events;
    }
}
