package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.SkillsRequest;
import com.kickpro.backend.dto.response.SkillsResponse;

public interface SkillsService {

    SkillsResponse createOrUpdateSkills(Long userId, SkillsRequest request);

    SkillsResponse getMySkills(Long userId);
}
