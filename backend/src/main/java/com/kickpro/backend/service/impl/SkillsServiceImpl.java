package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.SkillsRequest;
import com.kickpro.backend.dto.response.SkillsResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Skills;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.SkillsRepository;
import com.kickpro.backend.service.SkillsService;
import com.kickpro.backend.util.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SkillsServiceImpl implements SkillsService {

    private final SkillsRepository skillsRepository;
    private final PlayerProfileRepository playerProfileRepository;

    @Override
    @Transactional
    public SkillsResponse createOrUpdateSkills(Long userId, SkillsRequest request) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before setting skills"));

        Skills skills = skillsRepository.findByPlayerProfileId(profile.getId())
                .orElse(Skills.builder().playerProfile(profile).build());

        skills.setDribbling(request.getDribbling());
        skills.setShooting(request.getShooting());
        skills.setPassing(request.getPassing());
        skills.setSpeed(request.getSpeed());
        skills.setHeading(request.getHeading());
        skills.setStamina(request.getStamina());

        return toResponse(skillsRepository.save(skills));
    }

    @Override
    @Transactional(readOnly = true)
    public SkillsResponse getMySkills(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        Skills skills = skillsRepository.findByPlayerProfileId(profile.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Skills not found"));

        return toResponse(skills);
    }

    private SkillsResponse toResponse(Skills skills) {
        return SkillsResponse.builder()
                .id(skills.getId())
                .playerId(skills.getPlayerProfile().getId())
                .dribbling(skills.getDribbling())
                .shooting(skills.getShooting())
                .passing(skills.getPassing())
                .speed(skills.getSpeed())
                .heading(skills.getHeading())
                .stamina(skills.getStamina())
                .strengths(SecurityUtils.computeStrengths(skills))
                .weaknesses(SecurityUtils.computeWeaknesses(skills))
                .build();
    }
}
