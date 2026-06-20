package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.CreateWeeklyChallengeRequest;
import com.kickpro.backend.dto.request.SubmitChallengeRequest;
import com.kickpro.backend.dto.response.ChallengeSubmissionResponse;
import com.kickpro.backend.dto.response.WeeklyChallengeResponse;
import com.kickpro.backend.entity.ChallengeSubmission;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.WeeklyChallenge;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.ChallengeSubmissionRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.WeeklyChallengeRepository;
import com.kickpro.backend.service.ChallengeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChallengeServiceImpl implements ChallengeService {

    private final WeeklyChallengeRepository weeklyChallengeRepository;
    private final ChallengeSubmissionRepository challengeSubmissionRepository;
    private final PlayerProfileRepository playerProfileRepository;

    @Override
    @Transactional(readOnly = true)
    public WeeklyChallengeResponse getActiveChallenge() {
        WeeklyChallenge challenge = findActiveChallenge()
                .orElseThrow(() -> new ResourceNotFoundException("No active challenge found"));
        return toChallengeResponse(challenge);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ChallengeSubmissionResponse> getSubmissions(Long userId) {
        WeeklyChallenge challenge = findActiveChallenge()
                .orElseThrow(() -> new ResourceNotFoundException("No active challenge found"));
        Long viewerProfileId = resolveProfileId(userId);
        return challengeSubmissionRepository.findByChallengeIdOrderByVotesDescSubmittedAtAsc(challenge.getId())
                .stream()
                .map(submission -> toSubmissionResponse(submission, viewerProfileId))
                .toList();
    }

    @Override
    @Transactional
    public ChallengeSubmissionResponse submit(Long userId, SubmitChallengeRequest request) {
        WeeklyChallenge challenge = findActiveChallenge()
                .orElseThrow(() -> new ResourceNotFoundException("No active challenge found"));
        PlayerProfile player = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before submitting"));

        if (challengeSubmissionRepository.findByChallengeIdAndPlayerId(challenge.getId(), player.getId()).isPresent()) {
            throw new BadRequestException("You already submitted to this challenge");
        }

        ChallengeSubmission submission = ChallengeSubmission.builder()
                .challenge(challenge)
                .player(player)
                .videoUrl(request.getVideoUrl().trim())
                .build();
        submission = challengeSubmissionRepository.save(submission);
        return toSubmissionResponse(submission, player.getId());
    }

    @Override
    @Transactional
    public ChallengeSubmissionResponse vote(Long userId, Long submissionId) {
        ChallengeSubmission submission = challengeSubmissionRepository.findById(submissionId)
                .orElseThrow(() -> new ResourceNotFoundException("Submission not found"));
        Long voterProfileId = resolveProfileId(userId);
        if (submission.getPlayer().getId().equals(voterProfileId)) {
            throw new BadRequestException("You cannot vote for your own submission");
        }
        submission.setVotes(submission.getVotes() + 1);
        submission = challengeSubmissionRepository.save(submission);
        return toSubmissionResponse(submission, voterProfileId);
    }

    @Override
    @Transactional
    public WeeklyChallengeResponse createChallenge(CreateWeeklyChallengeRequest request) {
        if (request.getEndDate().isBefore(request.getStartDate())) {
            throw new BadRequestException("End date must be on or after start date");
        }
        WeeklyChallenge challenge = WeeklyChallenge.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription().trim())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .active(request.getActive() != null ? request.getActive() : true)
                .build();
        challenge = weeklyChallengeRepository.save(challenge);
        return toChallengeResponse(challenge);
    }

    private java.util.Optional<WeeklyChallenge> findActiveChallenge() {
        LocalDate today = LocalDate.now();
        return weeklyChallengeRepository
                .findFirstByActiveTrueAndStartDateLessThanEqualAndEndDateGreaterThanEqualOrderByStartDateDesc(
                        today, today);
    }

    private Long resolveProfileId(Long userId) {
        return playerProfileRepository.findByUserId(userId)
                .map(PlayerProfile::getId)
                .orElse(null);
    }

    private WeeklyChallengeResponse toChallengeResponse(WeeklyChallenge challenge) {
        return WeeklyChallengeResponse.builder()
                .id(challenge.getId())
                .title(challenge.getTitle())
                .description(challenge.getDescription())
                .startDate(challenge.getStartDate())
                .endDate(challenge.getEndDate())
                .active(challenge.getActive())
                .createdAt(challenge.getCreatedAt())
                .build();
    }

    private ChallengeSubmissionResponse toSubmissionResponse(ChallengeSubmission submission, Long viewerProfileId) {
        return ChallengeSubmissionResponse.builder()
                .id(submission.getId())
                .challengeId(submission.getChallenge().getId())
                .playerId(submission.getPlayer().getId())
                .playerName(submission.getPlayer().getFullName())
                .videoUrl(submission.getVideoUrl())
                .votes(submission.getVotes())
                .submittedAt(submission.getSubmittedAt())
                .ownSubmission(viewerProfileId != null && viewerProfileId.equals(submission.getPlayer().getId()))
                .build();
    }
}
