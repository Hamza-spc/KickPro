package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.entity.SubmissionStatus;
import com.kickpro.backend.entity.DrillSubmission;
import com.kickpro.backend.repository.CertificationRepository;
import com.kickpro.backend.repository.DrillSubmissionRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.PlayerProfileSpecifications;
import com.kickpro.backend.repository.SkillsRepository;
import com.kickpro.backend.service.PlayerSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PlayerSearchServiceImpl implements PlayerSearchService {

    private final PlayerProfileRepository playerProfileRepository;
    private final SkillsRepository skillsRepository;
    private final CertificationRepository certificationRepository;
    private final DrillSubmissionRepository drillSubmissionRepository;

    @Override
    @Transactional(readOnly = true)
    public Page<PlayerSearchResultResponse> searchPlayers(
            Position position,
            String city,
            PreferredFoot preferredFoot,
            Integer minAge,
            Integer maxAge,
            Double minCredibility,
            Double maxCredibility,
            Integer minDribbling,
            Integer minShooting,
            Integer minPassing,
            Integer minSpeed,
            Integer minHeading,
            Integer minStamina,
            Integer minDrillScore,
            Boolean hasCertification,
            Pageable pageable
    ) {
        Specification<PlayerProfile> spec = PlayerProfileSpecifications.withFilters(
                position,
                city,
                preferredFoot,
                minAge,
                maxAge,
                minCredibility,
                maxCredibility,
                minDribbling,
                minShooting,
                minPassing,
                minSpeed,
                minHeading,
                minStamina,
                minDrillScore,
                hasCertification
        );

        Page<PlayerProfile> profiles = playerProfileRepository.findAll(spec, pageable);
        List<Long> profileIds = profiles.getContent().stream()
                .map(PlayerProfile::getId)
                .toList();

        Map<Long, Skills> skillsByProfileId = profileIds.isEmpty()
                ? Map.of()
                : skillsRepository.findByPlayerProfileIdIn(profileIds).stream()
                        .collect(Collectors.toMap(skills -> skills.getPlayerProfile().getId(), skills -> skills));

        Map<Long, Long> certificationCounts = profileIds.stream()
                .collect(Collectors.toMap(id -> id, certificationRepository::countByPlayerId));

        Map<Long, List<DrillSubmission>> drillSubmissionsByProfile = profileIds.stream()
                .collect(Collectors.toMap(id -> id, drillSubmissionRepository::findByPlayerId));

        return profiles.map(profile -> {
            List<DrillSubmission> approvedDrills = drillSubmissionsByProfile
                    .getOrDefault(profile.getId(), List.of()).stream()
                    .filter(submission -> submission.getStatus() == SubmissionStatus.APPROVED)
                    .toList();

            Double averageDrillScore = approvedDrills.isEmpty()
                    ? null
                    : approvedDrills.stream()
                            .mapToInt(DrillSubmission::getScore)
                            .average()
                            .orElse(0.0);

            Skills skills = skillsByProfileId.get(profile.getId());
            PlayerSearchResultResponse.SkillsSummary skillsSummary = skills == null
                    ? null
                    : PlayerSearchResultResponse.SkillsSummary.builder()
                            .dribbling(skills.getDribbling())
                            .shooting(skills.getShooting())
                            .passing(skills.getPassing())
                            .speed(skills.getSpeed())
                            .heading(skills.getHeading())
                            .stamina(skills.getStamina())
                            .build();

            return PlayerSearchResultResponse.builder()
                    .profileId(profile.getId())
                    .fullName(profile.getFullName())
                    .city(profile.getCity())
                    .position(profile.getPosition())
                    .preferredFoot(profile.getPreferredFoot())
                    .dateOfBirth(profile.getDateOfBirth())
                    .profilePhotoUrl(profile.getProfilePhotoUrl())
                    .credibilityScore(profile.getCredibilityScore())
                    .certificationCount(certificationCounts.getOrDefault(profile.getId(), 0L))
                    .approvedDrillCount(approvedDrills.size())
                    .averageDrillScore(averageDrillScore)
                    .skills(skillsSummary)
                    .build();
        });
    }
}
