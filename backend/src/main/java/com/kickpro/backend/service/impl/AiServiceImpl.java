package com.kickpro.backend.service.impl;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kickpro.backend.dto.request.GenerateCourseRequest;
import com.kickpro.backend.dto.request.RecoveryPlanRequest;
import com.kickpro.backend.dto.request.ScoutAssistRequest;
import com.kickpro.backend.dto.request.VideoFeedbackRequest;
import com.kickpro.backend.dto.response.AiTextResponse;
import com.kickpro.backend.dto.response.DrillRecommendationResponse;
import com.kickpro.backend.dto.response.GeneratedCourseResponse;
import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.dto.response.ScoutAssistResponse;
import com.kickpro.backend.entity.Drill;
import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.entity.ParticipantStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.PlayerRating;
import com.kickpro.backend.entity.Video;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.exception.TooManyRequestsException;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.DrillRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.MatchParticipantRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerRatingRepository;
import com.kickpro.backend.repository.ReferralRepository;
import com.kickpro.backend.repository.SkillsRepository;
import com.kickpro.backend.repository.VideoRepository;
import com.kickpro.backend.service.AiService;
import com.kickpro.backend.service.CredibilityService;
import com.kickpro.backend.service.PlayerSearchService;
import com.kickpro.backend.util.AiJsonHelper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.google.genai.GoogleGenAiChatOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AiServiceImpl implements AiService {

    private final ChatClient chatClient;
    private final ObjectMapper objectMapper;
    private final PlayerSearchService playerSearchService;
    private final PlayerProfileRepository playerProfileRepository;
    private final SkillsRepository skillsRepository;
    private final DrillRepository drillRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;
    private final PlayerRatingRepository playerRatingRepository;
    private final CertificationRepository certificationRepository;
    private final CredibilityService credibilityService;
    private final MatchParticipantRepository matchParticipantRepository;
    private final ReferralRepository referralRepository;
    private final VideoRepository videoRepository;

    @Value("${spring.ai.google.genai.api-key:}")
    private String geminiApiKey;

    @Override
    @Transactional(readOnly = true)
    public ScoutAssistResponse scoutAssist(ScoutAssistRequest request) {
        assertApiKeyConfigured();

        List<PlayerSearchResultResponse> players = playerSearchService.searchPlayers(
                null, null, null, null,
                null, null, null, null,
                null, null, null, null, null, null, null,
                null,
                PageRequest.of(0, 50)
        ).getContent();

        if (players.isEmpty()) {
            return ScoutAssistResponse.builder()
                    .matchedPlayerIds(List.of())
                    .explanation("No players are registered yet.")
                    .build();
        }

        String playerJson = serializePlayers(players);
        String prompt = """
                A scout searched for: "%s"

                Here are available players (JSON):
                %s

                Pick the best matching players for this search.
                Return JSON only:
                {
                  "matchedPlayerIds": [1, 2],
                  "explanation": "Why these players match in plain English"
                }
                Use profileId values from the player list. Return at most 10 IDs.
                """.formatted(request.getQuery().trim(), playerJson);

        ScoutAssistJson parsed = AiJsonHelper.parseJson(
                objectMapper, callJson(prompt), ScoutAssistJson.class);

        return ScoutAssistResponse.builder()
                .matchedPlayerIds(parsed.matchedPlayerIds == null ? List.of() : parsed.matchedPlayerIds)
                .explanation(parsed.explanation == null ? "" : parsed.explanation)
                .build();
    }

    @Override
    @Transactional
    public AiTextResponse explainScore(Long userId) {
        assertApiKeyConfigured();
        PlayerProfile profile = loadPlayerProfile(userId);
        double score = credibilityService.recalculateForUser(userId);
        Map<String, Object> stats = buildPlayerStats(profile);
        stats.put("credibilityScore", score);
        stats.put("scoreBreakdown", credibilityService.buildScoreBreakdown(profile.getId()));
        stats.put("scoreTier", credibilityService.scoreTierLabel(score));
        stats.put("approvedMatchCount", matchParticipantRepository.countByPlayerIdAndStatus(
                profile.getId(), ParticipantStatus.APPROVED));
        stats.put("referralCount", referralRepository.countByReferrerId(userId));
        stats.put("ratedVideoCount", videoRepository.findByPlayerIdOrderByUploadedAtDesc(profile.getId()).stream()
                .filter(video -> video.getAverageRating() != null && video.getAverageRating() > 0)
                .count());

        String prompt = """
                Explain this player's KickPro credibility score in plain English (3-5 short paragraphs).
                Write directly to the player using "you". Do NOT use JSON.

                The player's credibility score is exactly %.1f out of 100. You MUST reference this number in your opening sentence.
                The required tone tier for this score is: %s. Your opening sentence MUST reflect this tier.

                Score calibration — use this tone strictly:
                - 0–30: needs significant improvement, just getting started. Never praise the score itself.
                - 31–50: below average, clear room to grow.
                - 51–70: average, making progress.
                - 71–85: good, standing out among peers.
                - 86–100: excellent, elite level.

                Rules:
                - NEVER call a score below 51 "impressive", "great", "strong", or "excellent".
                - Be honest and calibrated to the actual score above and the scoreBreakdown points (each out of its max: drillPerformance 25, drillConsistency 10, matchRatings 35, certifications 15, matchParticipation 10, videoRatings 5, referrals 25).
                - Identify the player's weakest areas from scoreBreakdown and stats (low component points, few drills, no certifications, low match ratings, etc.).
                - Give 2-3 specific, actionable steps tied to those weak areas.

                Player stats JSON:
                %s
                """.formatted(score, credibilityService.scoreTierLabel(score), toJson(stats));

        return AiTextResponse.builder().content(callText(prompt)).build();
    }

    @Override
    @Transactional(readOnly = true)
    public DrillRecommendationResponse recommendDrills(Long userId) {
        assertApiKeyConfigured();
        PlayerProfile profile = loadPlayerProfile(userId);
        Skills skills = skillsRepository.findByPlayerProfileId(profile.getId())
                .orElseThrow(() -> new BadRequestException("Save your skills before requesting drill recommendations"));

        List<Drill> drills = drillRepository.findAll().stream()
                .sorted(Comparator.comparing(Drill::getLevel).thenComparing(Drill::getProgressionOrder))
                .toList();

        if (drills.isEmpty()) {
            throw new BadRequestException("No drills available in the system yet");
        }

        String drillCatalog = drills.stream()
                .map(d -> "- id=%d | title=%s | level=%s | targetSkill=%s | order=%d"
                        .formatted(d.getId(), d.getTitle(), d.getLevel(), d.getTargetSkill(), d.getProgressionOrder()))
                .collect(Collectors.joining("\n"));

        String prompt = """
                Recommend 2-4 drills from the catalog below for this player.
                Prioritize weak skills (rated 1-4). Only use drill IDs from the catalog.

                Player skills JSON:
                %s

                Drill catalog:
                %s

                Return JSON only:
                {
                  "summary": "One sentence overview",
                  "recommendations": [
                    {
                      "drillId": 1,
                      "drillTitle": "Title from catalog",
                      "targetSkill": "SHOOTING",
                      "level": "BEGINNER",
                      "reason": "Why this drill helps"
                    }
                  ]
                }
                """.formatted(toJson(skills), drillCatalog);

        DrillRecommendationJson parsed = AiJsonHelper.parseJson(
                objectMapper, callJson(prompt), DrillRecommendationJson.class);

        List<DrillRecommendationResponse.Recommendation> recommendations = parsed.recommendations == null
                ? List.of()
                : parsed.recommendations.stream()
                        .map(r -> DrillRecommendationResponse.Recommendation.builder()
                                .drillId(r.drillId)
                                .drillTitle(r.drillTitle)
                                .targetSkill(r.targetSkill)
                                .level(r.level)
                                .reason(r.reason)
                                .build())
                        .toList();

        return DrillRecommendationResponse.builder()
                .summary(parsed.summary == null ? "" : parsed.summary)
                .recommendations(recommendations)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public AiTextResponse generateMealPlan(Long userId) {
        assertApiKeyConfigured();
        PlayerProfile profile = loadPlayerProfile(userId);
        int age = Period.between(profile.getDateOfBirth(), LocalDate.now()).getYears();

        String prompt = """
                Create a football-specific daily nutrition plan for this player.
                NOT bodybuilding. NOT marathon running. Football only.

                Include:
                - Total calories, protein, carbs, fats
                - Match day meals (pre-match, half-time, post-match)
                - Training day meals
                - Rest day meals
                Adjust for age and position.

                Player JSON:
                {
                  "age": %d,
                  "heightCm": %d,
                  "weightKg": %d,
                  "position": "%s"
                }

                Write in clear sections with bullet points. Do NOT use JSON.
                """.formatted(age, profile.getHeight(), profile.getWeight(), profile.getPosition());

        return AiTextResponse.builder().content(callText(prompt)).build();
    }

    @Override
    @Transactional(readOnly = true)
    public AiTextResponse generateRecoveryPlan(Long userId, RecoveryPlanRequest request) {
        assertApiKeyConfigured();
        PlayerProfile profile = loadPlayerProfile(userId);
        int age = Period.between(profile.getDateOfBirth(), LocalDate.now()).getYears();

        String prompt = """
                Create a football player recovery plan combining nutrition and safe rehabilitation exercises.
                The player is injured — avoid intense performance drills.

                Injury JSON:
                {
                  "injuryType": "%s",
                  "bodyPart": "%s",
                  "severity": "%s"
                }

                Player JSON:
                {
                  "age": %d,
                  "heightCm": %d,
                  "weightKg": %d,
                  "position": "%s"
                }

                Include recovery nutrition and gentle rehab exercises appropriate for the injury.
                Write in clear sections. Do NOT use JSON.
                """.formatted(
                request.getInjuryType(),
                request.getBodyPart(),
                request.getSeverity(),
                age,
                profile.getHeight(),
                profile.getWeight(),
                profile.getPosition());

        return AiTextResponse.builder().content(callText(prompt)).build();
    }

    @Override
    public GeneratedCourseResponse generateCourse(GenerateCourseRequest request) {
        assertApiKeyConfigured();

        String prompt = """
                Generate a KickPro certification course for football players.

                Title: %s
                Description: %s

                Return JSON only with this structure:
                {
                  "title": "Course title",
                  "description": "Course description",
                  "level": "BEGINNER",
                  "lessons": [
                    {
                      "title": "Lesson title",
                      "content": "Lesson content (2-4 paragraphs)",
                      "orderIndex": 1,
                      "quiz": null
                    },
                    {
                      "title": "Final lesson title",
                      "content": "Final lesson content",
                      "orderIndex": 2,
                      "quiz": {
                        "questions": [
                          {
                            "question": "Question text",
                            "options": ["A", "B", "C", "D"],
                            "correctAnswerIndex": 0
                          }
                        ]
                      }
                    }
                  ]
                }

                Rules:
                - level must be BEGINNER, INTERMEDIATE, or ADVANCED
                - 2-3 lessons total
                - only the final lesson has a quiz with 3-5 questions
                - each question has exactly 4 options
                """.formatted(request.getTitle().trim(), request.getDescription().trim());

        GeneratedCourseJson parsed = AiJsonHelper.parseJson(
                objectMapper, callJson(prompt), GeneratedCourseJson.class);

        return mapGeneratedCourse(parsed);
    }

    @Override
    public AiTextResponse generateVideoFeedback(VideoFeedbackRequest request) {
        assertApiKeyConfigured();

        String skill = request.getSkillTag() != null && !request.getSkillTag().isBlank()
                ? request.getSkillTag().trim()
                : "general football skills";

        String prompt = """
                You are a professional football scout analyzing a player video.
                The video URL is: %s
                Focus skill area: %s

                You cannot watch the video directly, but provide a structured scouting report template
                a scout would use when reviewing footage for this skill area. Include:
                1. Technical observations to look for
                2. Tactical awareness indicators
                3. Physical attributes visible in video
                4. Strengths to highlight
                5. Areas for improvement
                6. Overall scouting recommendation (watch again / invite to trial / not ready)

                Write in clear sections for a scout audience. Do NOT use JSON.
                """.formatted(request.getVideoUrl().trim(), skill);

        return AiTextResponse.builder().content(callText(prompt)).build();
    }

    private String callText(String userPrompt) {
        return callWithRetry(() -> chatClient.prompt()
                .user(userPrompt)
                .call()
                .content(), "Gemini text call");
    }

    private String callJson(String userPrompt) {
        return callWithRetry(() -> chatClient.prompt()
                .user(userPrompt)
                .options(GoogleGenAiChatOptions.builder()
                        .responseMimeType("application/json")
                        .build())
                .call()
                .content(), "Gemini JSON call");
    }

    private String callWithRetry(java.util.function.Supplier<String> action, String label) {
        Exception last = null;
        for (int attempt = 1; attempt <= 3; attempt++) {
            try {
                return action.get();
            } catch (Exception ex) {
                last = ex;
                if (isRateLimitError(ex)) {
                    break;
                }
                if (attempt < 3 && isRetryableGeminiError(ex)) {
                    long delayMs = 1000L * attempt;
                    log.warn("{} attempt {} failed, retrying in {}ms: {}", label, attempt, delayMs, ex.getMessage());
                    try {
                        Thread.sleep(delayMs);
                    } catch (InterruptedException ie) {
                        Thread.currentThread().interrupt();
                        throw new BadRequestException("AI request interrupted");
                    }
                } else {
                    break;
                }
            }
        }
        log.error("{} failed", label, last);
        if (isRateLimitError(last)) {
            throw new TooManyRequestsException(
                    "Gemini rate limit exceeded. Wait a minute and try again.");
        }
        throw new BadRequestException("AI request failed: " + last.getMessage());
    }

    private boolean isRateLimitError(Throwable ex) {
        if (ex == null) {
            return false;
        }
        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";
        Throwable cause = ex.getCause();
        if (cause != null && cause.getMessage() != null) {
            msg = msg + " " + cause.getMessage().toLowerCase();
        }
        return msg.contains("429") || msg.contains("quota") || msg.contains("rate");
    }

    private boolean isRetryableGeminiError(Exception ex) {
        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";
        Throwable cause = ex.getCause();
        if (cause != null && cause.getMessage() != null) {
            msg = msg + " " + cause.getMessage().toLowerCase();
        }
        return msg.contains("expired") || msg.contains("quota") || msg.contains("429")
                || msg.contains("rate") || msg.contains("unavailable");
    }

    private void assertApiKeyConfigured() {
        if (geminiApiKey == null || geminiApiKey.isBlank()) {
            throw new BadRequestException("GEMINI_API_KEY is not configured");
        }
    }

    private PlayerProfile loadPlayerProfile(Long userId) {
        return playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
    }

    private Map<String, Object> buildPlayerStats(PlayerProfile profile) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("fullName", profile.getFullName());
        stats.put("credibilityScore", profile.getCredibilityScore());
        stats.put("city", profile.getCity());
        stats.put("position", profile.getPosition());

        skillsRepository.findByPlayerProfileId(profile.getId()).ifPresent(skills -> {
            stats.put("skills", Map.of(
                    "dribbling", skills.getDribbling(),
                    "shooting", skills.getShooting(),
                    "passing", skills.getPassing(),
                    "speed", skills.getSpeed(),
                    "heading", skills.getHeading(),
                    "stamina", skills.getStamina()
            ));
        });

        List<DrillSubmission> approved = drillSubmissionRepository.findByPlayerId(profile.getId()).stream()
                .filter(s -> s.getStatus() == SubmissionStatus.APPROVED)
                .toList();
        stats.put("approvedDrillCount", approved.size());
        if (!approved.isEmpty()) {
            stats.put("averageDrillScore", approved.stream()
                    .mapToInt(DrillSubmission::getScore)
                    .average()
                    .orElse(0));
        }

        List<PlayerRating> ratings = playerRatingRepository.findByRatedPlayerId(profile.getId());
        if (!ratings.isEmpty()) {
            stats.put("averageMatchRating", ratings.stream()
                    .mapToDouble(r -> (r.getPerformanceScore() + r.getPunctualityScore()
                            + r.getTeamworkScore() + r.getBehaviorScore()) / 4.0)
                    .average()
                    .orElse(0));
        }

        stats.put("certificationCount", certificationRepository.countByPlayerId(profile.getId()));
        return stats;
    }

    private String serializePlayers(List<PlayerSearchResultResponse> players) {
        List<Map<String, Object>> simplified = new ArrayList<>();
        for (PlayerSearchResultResponse player : players) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("profileId", player.getProfileId());
            row.put("fullName", player.getFullName());
            row.put("city", player.getCity());
            row.put("position", player.getPosition());
            row.put("preferredFoot", player.getPreferredFoot());
            row.put("credibilityScore", player.getCredibilityScore());
            row.put("certificationCount", player.getCertificationCount());
            row.put("approvedDrillCount", player.getApprovedDrillCount());
            row.put("averageDrillScore", player.getAverageDrillScore());
            if (player.getSkills() != null) {
                row.put("skills", player.getSkills());
            }
            simplified.add(row);
        }
        return toJson(simplified);
    }

    private String toJson(Object value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception ex) {
            throw new BadRequestException("Failed to serialize data for AI request");
        }
    }

    private GeneratedCourseResponse mapGeneratedCourse(GeneratedCourseJson parsed) {
        List<GeneratedCourseResponse.GeneratedLessonResponse> lessons = parsed.lessons == null
                ? List.of()
                : parsed.lessons.stream()
                        .map(lesson -> {
                            GeneratedCourseResponse.GeneratedQuizResponse quiz = null;
                            if (lesson.quiz != null && lesson.quiz.questions != null) {
                                quiz = GeneratedCourseResponse.GeneratedQuizResponse.builder()
                                        .questions(lesson.quiz.questions.stream()
                                                .map(q -> GeneratedCourseResponse.GeneratedQuestionResponse.builder()
                                                        .question(q.question)
                                                        .options(q.options)
                                                        .correctAnswerIndex(q.correctAnswerIndex)
                                                        .build())
                                                .toList())
                                        .build();
                            }
                            return GeneratedCourseResponse.GeneratedLessonResponse.builder()
                                    .title(lesson.title)
                                    .content(lesson.content)
                                    .orderIndex(lesson.orderIndex)
                                    .quiz(quiz)
                                    .build();
                        })
                        .toList();

        return GeneratedCourseResponse.builder()
                .title(parsed.title)
                .description(parsed.description)
                .level(parsed.level)
                .lessons(lessons)
                .build();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class ScoutAssistJson {
        public List<Long> matchedPlayerIds;
        public String explanation;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class DrillRecommendationJson {
        public String summary;
        public List<DrillRecommendationItemJson> recommendations;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class DrillRecommendationItemJson {
        public Long drillId;
        public String drillTitle;
        public String targetSkill;
        public String level;
        public String reason;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GeneratedCourseJson {
        public String title;
        public String description;
        public com.kickpro.backend.entity.DrillLevel level;
        public List<GeneratedLessonJson> lessons;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GeneratedLessonJson {
        public String title;
        public String content;
        public Integer orderIndex;
        public GeneratedQuizJson quiz;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GeneratedQuizJson {
        public List<GeneratedQuestionJson> questions;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private static class GeneratedQuestionJson {
        public String question;
        public List<String> options;
        public Integer correctAnswerIndex;
    }
}
