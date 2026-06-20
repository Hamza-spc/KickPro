package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.DrillReviewRequest;
import com.kickpro.backend.dto.response.BadgeResponse;
import com.kickpro.backend.dto.response.DrillProgressionResponse;
import com.kickpro.backend.dto.response.DrillSubmissionResponse;
import com.kickpro.backend.entity.Badge;
import com.kickpro.backend.entity.BadgeType;
import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillLevel;
import com.kickpro.backend.entity.DrillProgressStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.NotificationType;
import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.event.DrillSubmittedEvent;
import com.kickpro.backend.event.KafkaEventPublisher;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.BadgeRepository;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.service.CredibilityService;
import com.kickpro.backend.service.DrillService;
import com.kickpro.backend.service.NotificationService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class DrillServiceImpl implements DrillService {

    private final DrillRepository drillRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final BadgeRepository badgeRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final CloudinaryService cloudinaryService;
    private final KafkaEventPublisher kafkaEventPublisher;
    private final CredibilityService credibilityService;
    private final NotificationService notificationService;

    @Override
    @Transactional(readOnly = true)
    public List<DrillProgressionResponse> getProgression(Long userId, DrillLevel level) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        List<Drill> drills = drillRepository.findByLevelOrderByProgressionOrderAsc(level);
        Set<Long> approvedDrillIds = new HashSet<>();
        drillSubmissionRepository.findByPlayerId(player.getId()).stream()
                .filter(submission -> submission.getStatus() == SubmissionStatus.APPROVED)
                .forEach(submission -> approvedDrillIds.add(submission.getDrill().getId()));

        List<DrillProgressionResponse> result = new ArrayList<>();
        boolean currentAssigned = false;

        for (Drill drill : drills) {
            DrillProgressStatus status;
            if (approvedDrillIds.contains(drill.getId())) {
                status = DrillProgressStatus.COMPLETED;
            } else if (isUnlocked(drill, drills, approvedDrillIds)) {
                if (!currentAssigned) {
                    status = DrillProgressStatus.CURRENT;
                    currentAssigned = true;
                } else {
                    status = DrillProgressStatus.LOCKED;
                }
            } else {
                status = DrillProgressStatus.LOCKED;
            }

            result.add(toProgressionResponse(drill, status));
        }

        return result;
    }

    @Override
    @Transactional
    public DrillSubmissionResponse submitDrill(Long userId, Long drillId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Video file is required");
        }

        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before submitting drills"));

        Drill drill = drillRepository.findById(drillId)
                .orElseThrow(() -> new ResourceNotFoundException("Drill not found"));

        List<Drill> levelDrills = drillRepository.findByLevelOrderByProgressionOrderAsc(drill.getLevel());
        Set<Long> approvedDrillIds = new HashSet<>();
        drillSubmissionRepository.findByPlayerId(player.getId()).stream()
                .filter(submission -> submission.getStatus() == SubmissionStatus.APPROVED)
                .forEach(submission -> approvedDrillIds.add(submission.getDrill().getId()));

        if (!isUnlocked(drill, levelDrills, approvedDrillIds)) {
            throw new BadRequestException("This drill is locked. Complete previous drills first.");
        }

        if (drillSubmissionRepository.existsByPlayerIdAndDrillIdAndStatus(
                player.getId(), drillId, SubmissionStatus.PENDING)) {
            throw new BadRequestException("You already have a pending submission for this drill");
        }

        if (approvedDrillIds.contains(drillId)) {
            throw new BadRequestException("You have already completed this drill");
        }

        try {
            String publicId = "drill-" + drillId + "-player-" + player.getId() + "-" + System.currentTimeMillis();
            String videoUrl = cloudinaryService.uploadVideo(file, "kickpro/drill-submissions", publicId);

            DrillSubmission submission = DrillSubmission.builder()
                    .player(player)
                    .drill(drill)
                    .videoCloudinaryUrl(videoUrl)
                    .status(SubmissionStatus.PENDING)
                    .build();

            DrillSubmission saved = drillSubmissionRepository.save(submission);

            kafkaEventPublisher.publishDrillSubmitted(DrillSubmittedEvent.builder()
                    .submissionId(saved.getId())
                    .playerId(player.getId())
                    .drillId(drill.getId())
                    .videoUrl(saved.getVideoCloudinaryUrl())
                    .submittedAt(saved.getSubmittedAt())
                    .build());

            return toSubmissionResponse(saved);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload drill video");
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<BadgeResponse> getMyBadges(Long userId) {
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        return badgeRepository.findByPlayerIdOrderByEarnedAtDesc(player.getId())
                .stream()
                .map(this::toBadgeResponse)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<DrillSubmissionResponse> getPendingSubmissions() {
        return drillSubmissionRepository.findByStatusOrderBySubmittedAtAsc(SubmissionStatus.PENDING)
                .stream()
                .map(this::toSubmissionResponse)
                .toList();
    }

    @Override
    @Transactional
    public DrillSubmissionResponse reviewSubmission(Long adminUserId, Long submissionId, DrillReviewRequest request) {
        if (request.getStatus() != SubmissionStatus.APPROVED && request.getStatus() != SubmissionStatus.REJECTED) {
            throw new BadRequestException("Review status must be APPROVED or REJECTED");
        }
        if (request.getStatus() == SubmissionStatus.APPROVED
                && (request.getScore() == null || request.getScore() < 0 || request.getScore() > 100)) {
            throw new BadRequestException("Score between 0 and 100 is required when approving");
        }

        DrillSubmission submission = drillSubmissionRepository.findById(submissionId)
                .orElseThrow(() -> new ResourceNotFoundException("Submission not found"));

        if (submission.getStatus() != SubmissionStatus.PENDING) {
            throw new BadRequestException("Submission has already been reviewed");
        }

        submission.setStatus(request.getStatus());
        submission.setReviewedAt(LocalDateTime.now());
        submission.setReviewedBy(adminUserId);

        if (request.getStatus() == SubmissionStatus.APPROVED) {
            submission.setScore(request.getScore());
            awardBadgeIfMissing(submission);
        } else {
            submission.setScore(null);
        }

        DrillSubmission saved = drillSubmissionRepository.save(submission);
        if (saved.getStatus() == SubmissionStatus.APPROVED) {
            credibilityService.recalculateForPlayer(saved.getPlayer().getId());
            notificationService.notifyUser(
                    saved.getPlayer().getUser().getId(),
                    "Drill approved",
                    "Your drill \"" + saved.getDrill().getTitle() + "\" was approved",
                    NotificationType.DRILL_APPROVED,
                    "DRILL",
                    saved.getDrill().getId()
            );
        } else {
            notificationService.notifyUser(
                    saved.getPlayer().getUser().getId(),
                    "Drill rejected",
                    "Your drill \"" + saved.getDrill().getTitle() + "\" was not approved",
                    NotificationType.DRILL_REJECTED,
                    "DRILL",
                    saved.getDrill().getId()
            );
        }
        return toSubmissionResponse(saved);
    }

    private void awardBadgeIfMissing(DrillSubmission submission) {
        if (badgeRepository.findByPlayerIdAndDrillId(
                submission.getPlayer().getId(), submission.getDrill().getId()).isPresent()) {
            return;
        }

        Badge badge = Badge.builder()
                .player(submission.getPlayer())
                .drill(submission.getDrill())
                .badgeType(BadgeType.DRILL_COMPLETION)
                .build();
        badgeRepository.save(badge);
    }

    private boolean isUnlocked(Drill drill, List<Drill> levelDrills, Set<Long> approvedDrillIds) {
        if (drill.getParentDrill() != null
                && !approvedDrillIds.contains(drill.getParentDrill().getId())) {
            return false;
        }

        for (Drill candidate : levelDrills) {
            if (candidate.getProgressionOrder() >= drill.getProgressionOrder()) {
                break;
            }
            if (!approvedDrillIds.contains(candidate.getId())) {
                return false;
            }
        }

        return true;
    }

    private DrillProgressionResponse toProgressionResponse(Drill drill, DrillProgressStatus status) {
        return DrillProgressionResponse.builder()
                .id(drill.getId())
                .title(drill.getTitle())
                .description(drill.getDescription())
                .rules(drill.getRules())
                .level(drill.getLevel())
                .progressionOrder(drill.getProgressionOrder())
                .parentDrillId(drill.getParentDrill() != null ? drill.getParentDrill().getId() : null)
                .targetSkill(drill.getTargetSkill())
                .status(status)
                .build();
    }

    private DrillSubmissionResponse toSubmissionResponse(DrillSubmission submission) {
        return DrillSubmissionResponse.builder()
                .id(submission.getId())
                .playerId(submission.getPlayer().getId())
                .playerName(submission.getPlayer().getFullName())
                .drillId(submission.getDrill().getId())
                .drillTitle(submission.getDrill().getTitle())
                .videoCloudinaryUrl(submission.getVideoCloudinaryUrl())
                .status(submission.getStatus())
                .score(submission.getScore())
                .submittedAt(submission.getSubmittedAt())
                .reviewedAt(submission.getReviewedAt())
                .reviewedBy(submission.getReviewedBy())
                .build();
    }

    private BadgeResponse toBadgeResponse(Badge badge) {
        return BadgeResponse.builder()
                .id(badge.getId())
                .playerId(badge.getPlayer().getId())
                .drillId(badge.getDrill().getId())
                .drillTitle(badge.getDrill().getTitle())
                .earnedAt(badge.getEarnedAt())
                .badgeType(badge.getBadgeType())
                .build();
    }
}
