package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.request.PlayerProfileRequest;
import com.kickpro.backend.dto.response.PlayerProfileResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerFollowRepository;
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
    private final PlayerFollowRepository playerFollowRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;

    @Override
    @Transactional
    public PlayerProfileResponse createOrUpdateProfile(Long userId, PlayerProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElse(PlayerProfile.builder().user(user).build());

        boolean isNew = profile.getId() == null;
        if (isNew) {
            validateCompleteProfileRequest(request);
        }
        applyProfileFields(profile, request);

        if (profile.getCredibilityScore() == null) {
            profile.setCredibilityScore(0.0);
        }

        return toResponse(playerProfileRepository.save(profile), userId);
    }

    private void validateCompleteProfileRequest(PlayerProfileRequest request) {
        if (request.getFullName() == null || request.getFullName().isBlank()) {
            throw new BadRequestException("Full name is required");
        }
        if (request.getDateOfBirth() == null) {
            throw new BadRequestException("Date of birth is required");
        }
        if (request.getCity() == null || request.getCity().isBlank()) {
            throw new BadRequestException("City is required");
        }
        if (request.getPosition() == null) {
            throw new BadRequestException("Position is required");
        }
        if (request.getPreferredFoot() == null) {
            throw new BadRequestException("Preferred foot is required");
        }
        if (request.getHeight() == null) {
            throw new BadRequestException("Height is required");
        }
        if (request.getWeight() == null) {
            throw new BadRequestException("Weight is required");
        }
    }

    private void applyProfileFields(PlayerProfile profile, PlayerProfileRequest request) {
        if (request.getFullName() != null && !request.getFullName().isBlank()) {
            profile.setFullName(request.getFullName().trim());
        }
        if (request.getDateOfBirth() != null) {
            profile.setDateOfBirth(request.getDateOfBirth());
        }
        if (request.getCity() != null && !request.getCity().isBlank()) {
            profile.setCity(request.getCity().trim());
        }
        if (request.getPosition() != null) {
            profile.setPosition(request.getPosition());
        }
        if (request.getPreferredFoot() != null) {
            profile.setPreferredFoot(request.getPreferredFoot());
        }
        if (request.getBio() != null) {
            profile.setBio(request.getBio().isBlank() ? null : request.getBio().trim());
        }
        if (request.getHeight() != null) {
            profile.setHeight(request.getHeight());
        }
        if (request.getWeight() != null) {
            profile.setWeight(request.getWeight());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public PlayerProfileResponse getMyProfile(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return toResponse(profile, userId);
    }

    @Override
    @Transactional(readOnly = true)
    public PlayerProfileResponse getProfileById(Long profileId, Long viewerUserId) {
        PlayerProfile profile = playerProfileRepository.findById(profileId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));
        return toResponse(profile, viewerUserId);
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
            return toResponse(playerProfileRepository.save(profile), userId);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to upload profile photo");
        }
    }

    @Override
    @Transactional
    public PlayerProfileResponse deleteProfilePhoto(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new BadRequestException("Create your profile before managing a photo"));

        if (profile.getProfilePhotoUrl() == null) {
            return toResponse(profile, userId);
        }

        try {
            cloudinaryService.deleteProfilePhoto(userId);
        } catch (IOException ex) {
            throw new BadRequestException("Failed to delete profile photo");
        }

        profile.setProfilePhotoUrl(null);
        return toResponse(playerProfileRepository.save(profile), userId);
    }

    private PlayerProfileResponse toResponse(PlayerProfile profile, Long viewerUserId) {
        Long profileUserId = profile.getUser().getId();
        boolean ownProfile = viewerUserId != null && viewerUserId.equals(profileUserId);
        boolean following = viewerUserId != null && !ownProfile
                && playerFollowRepository.existsByFollowerIdAndFollowingId(viewerUserId, profile.getId());

        return PlayerProfileResponse.builder()
                .id(profile.getId())
                .userId(profileUserId)
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
                .followersCount(playerFollowRepository.countByFollowingId(profile.getId()))
                .followingCount(playerFollowRepository.countByFollowerId(profileUserId))
                .following(following)
                .ownProfile(ownProfile)
                .createdAt(profile.getCreatedAt())
                .updatedAt(profile.getUpdatedAt())
                .build();
    }
}
