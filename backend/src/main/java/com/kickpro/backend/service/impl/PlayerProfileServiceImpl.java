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

        return toResponse(playerProfileRepository.save(profile), userId);
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
