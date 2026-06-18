package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.PlayerProfileRequest;
import com.kickpro.backend.dto.response.PlayerProfileResponse;
import org.springframework.web.multipart.MultipartFile;

public interface PlayerProfileService {

    PlayerProfileResponse createOrUpdateProfile(Long userId, PlayerProfileRequest request);

    PlayerProfileResponse getMyProfile(Long userId);

    PlayerProfileResponse getProfileById(Long profileId);

    PlayerProfileResponse uploadProfilePhoto(Long userId, MultipartFile file);
}
