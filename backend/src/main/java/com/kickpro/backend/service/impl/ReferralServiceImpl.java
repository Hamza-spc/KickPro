package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.ReferralResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Referral;
import com.kickpro.backend.entity.User;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.repository.ReferralRepository;
import com.kickpro.backend.repository.UserRepository;
import com.kickpro.backend.service.CredibilityService;
import com.kickpro.backend.service.ReferralService;
import com.kickpro.backend.util.ReferralCodeUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ReferralServiceImpl implements ReferralService {

    private final ReferralRepository referralRepository;
    private final PlayerProfileRepository playerProfileRepository;
    private final UserRepository userRepository;
    private final CredibilityService credibilityService;

    @Override
    @Transactional
    public ReferralResponse getMyReferralInfo(Long userId) {
        PlayerProfile profile = playerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found"));

        ensureReferralCode(profile);

        return ReferralResponse.builder()
                .code(profile.getReferralCode())
                .referralCount(referralRepository.countByReferrerId(userId))
                .build();
    }

    @Override
    @Transactional
    public ReferralResponse applyReferralCode(Long userId, String code) {
        Referral referral = applyCode(userId, code);
        return ReferralResponse.builder()
                .code(referral.getCode())
                .referralCount(referralRepository.countByReferrerId(referral.getReferrer().getId()))
                .appliedAt(referral.getCreatedAt())
                .build();
    }

    @Override
    @Transactional
    public void applyReferralOnRegister(Long newUserId, String code) {
        if (code == null || code.isBlank()) {
            return;
        }
        applyCode(newUserId, code);
    }

    private Referral applyCode(Long userId, String code) {
        if (referralRepository.existsByReferredId(userId)) {
            throw new BadRequestException("Referral code already applied");
        }

        PlayerProfile referrerProfile = playerProfileRepository.findByReferralCodeIgnoreCase(code.trim())
                .orElseThrow(() -> new BadRequestException("Invalid referral code"));

        User referrer = referrerProfile.getUser();
        User referred = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (referrer.getId().equals(userId)) {
            throw new BadRequestException("You cannot use your own referral code");
        }

        Referral referral = Referral.builder()
                .referrer(referrer)
                .referred(referred)
                .code(code.trim().toUpperCase())
                .build();

        Referral saved = referralRepository.save(referral);
        credibilityService.recalculateForUser(referrer.getId());
        return saved;
    }

    private void ensureReferralCode(PlayerProfile profile) {
        if (profile.getReferralCode() != null && !profile.getReferralCode().isBlank()) {
            return;
        }
        String code;
        do {
            code = ReferralCodeUtil.generate();
        } while (playerProfileRepository.findByReferralCodeIgnoreCase(code).isPresent());
        profile.setReferralCode(code);
        playerProfileRepository.save(profile);
    }
}
