package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.PlayerProfileRequest;
import com.kickpro.backend.dto.response.PlayerProfileResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.PlayerProfileService;
import com.kickpro.backend.util.CloudinaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Service
@RequiredArgsConstructor
public class PlayerProfileServiceImpl implements PlayerProfileService {

    private final PlayerProfileRepository playerProfileRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    @Transactional
    public PlayerProfileResponse createOrUpdateProfile(Long userId, PlayerProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElse(PlayerProfile.builder().user(user).build());

        profile.setFullName(request.getFullName().trim());
        profile.setDateOfBirth(request.getDateOfBirth());
        profile.setCity(request.getCity().trim());
        profile.setPosition(request.getPosition());
        profile.setPreferredFoot(request.getPreferredFoot());
        profile.setBio(request.getBio());
        profile.setHeight(request.getHeight());
        profile.setWeight(request.getWeight());

        if (profile.getCredibilityScore() == null) {
            profile.setCredibilityScore(0.0);
        }

        return toResponse(playerProfileRepository.save(profile));
    }

    @Override
    @Transactional(readOnly = true)
    public PlayerProfileResponse getMyProfile(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return toResponse(profile);
    }

    @Override
    @Transactional(readOnly = true)
    public PlayerProfileResponse getProfileById(Long profileId) {
        PlayerProfile profile = playerProfileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return toResponse(profile);
    }

    @Override
    @Transactional
    public PlayerProfileResponse uploadProfilePhoto(Long userId, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Photo file is required");
        }

        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before uploading a photo"));

        try {
            String photoUrl = cloudinaryService.uploadProfilePhoto(file, userId);
            profile.setProfilePhotoUrl(photoUrl);
            return toResponse(playerProfileRepository.save(profile));
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload profile photo");
        }
    }

    private PlayerProfileResponse toResponse(PlayerProfile profile) {
        return PlayerProfileResponse.builder()
                .id(profile.getId())
                .userId(profile.getUser().getId())
                .fullName(profile.getFullName())
                .dateOfBirth(profile.getDateOfBirth())
                .city(profile.getCity())
                .position(profile.getPosition())
                .preferredFoot(profile.getPreferredFoot())
                .bio(profile.getBio())
                .height(profile.getHeight())
                .weight(profile.getWeight())
                .profilePhotoUrl(profile.getProfilePhotoUrl())
                .credibilityScore(profile.getCredibilityScore())
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }
}
