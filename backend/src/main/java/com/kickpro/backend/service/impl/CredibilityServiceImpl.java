package com.kickpro.backend.service.impl;

import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.PlayerRating;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.service.CredibilityService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CredibilityServiceImpl implements CredibilityService {

    private static final double DRILL_SCORE_WEIGHT = 25.0;
    private static final double DRILL_COUNT_WEIGHT = 10.0;
    private static final double MATCH_RATING_WEIGHT = 35.0;
    private static final double CERTIFICATION_WEIGHT = 15.0;
    private static final double PARTICIPATION_WEIGHT = 10.0;
    private static final double VIDEO_RATING_WEIGHT = 5.0;
    private static final int PASSING_SCORE_PERCENT = 70;

    private final PlayerProfileRepository playerProfileRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final PlayerRatingRepository playerRatingRepository;
    private final CertificationRepository certificationRepository;
    private final MatchParticipantRepository matchParticipantRepository;
    private final VideoRepository videoRepository;

    @Override
    @Transactional
    public double recalculateForPlayer(Long playerProfileId) {
        PlayerProfile profile = playerProfileRepository.findById(playerProfileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        double score = computeScore(playerProfileId);
        profile.setCredibilityScore(score);
        playerProfileRepository.save(profile);
        return score;
    }

    @Override
    @Transactional
    public double recalculateForUser(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return recalculateForPlayer(profile.getId());
    }

    double computeScore(Long playerProfileId) {
        double score = 0.0;

        List<DrillSubmission> approvedDrills = drillSubmissionRepository.findByPlayerId(playerProfileId).stream()
                .filter(submission -> submission.getStatus() == SubmissionStatus.APPROVED)
                .toList();

        if (!approvedDrills.isEmpty()) {
            double avgDrillScore = approvedDrills.stream()
                    .mapToInt(DrillSubmission::getScore)
                    .average()
                    .orElse(0.0);
            score += Math.min(DRILL_SCORE_WEIGHT, avgDrillScore * DRILL_SCORE_WEIGHT / 100.0);
            score += Math.min(DRILL_COUNT_WEIGHT, approvedDrills.size() * 2.0);
        }

        List<PlayerRating> matchRatings = playerRatingRepository.findByRatedPlayerId(playerProfileId);
        if (!matchRatings.isEmpty()) {
            double avgMatchRating = matchRatings.stream()
                    .mapToDouble(rating -> (
                            rating.getPerformanceScore()
                                    + rating.getPunctualityScore()
                                    + rating.getTeamworkScore()
                                    + rating.getBehaviorScore()
                    ) / 4.0)
                    .average()
                    .orElse(0.0);
            score += (avgMatchRating / 5.0) * MATCH_RATING_WEIGHT;
        }

        long certificationCount = certificationRepository.countByPlayerId(playerProfileId);
        score += Math.min(CERTIFICATION_WEIGHT, certificationCount * 5.0);

        long approvedMatches = matchParticipantRepository.countByPlayerIdAndStatus(
                playerProfileId, ParticipantStatus.APPROVED);
        score += Math.min(PARTICIPATION_WEIGHT, approvedMatches * 2.0);

        List<Video> videos = videoRepository.findByPlayerIdOrderByUploadedAtDesc(playerProfileId);
        List<Video> ratedVideos = videos.stream()
                .filter(video -> video.getAverageRating() != null && video.getAverageRating() > 0)
                .toList();
        if (!ratedVideos.isEmpty()) {
            double avgVideoRating = ratedVideos.stream()
                    .mapToDouble(Video::getAverageRating)
                    .average()
                    .orElse(0.0);
            score += Math.min(VIDEO_RATING_WEIGHT, (avgVideoRating / 10.0) * VIDEO_RATING_WEIGHT);
        }

        return Math.min(100.0, Math.round(score * 10.0) / 10.0);
    }

    static boolean isPassingQuizScore(int correctCount, int totalQuestions) {
        if (totalQuestions == 0) {
            return false;
        }
        int scorePercent = (correctCount * 100) / totalQuestions;
        return scorePercent >= PASSING_SCORE_PERCENT;
    }
}
