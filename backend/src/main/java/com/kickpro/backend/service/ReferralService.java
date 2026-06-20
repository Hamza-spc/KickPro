package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.ReferralResponse;

public interface ReferralService {

    ReferralResponse getMyReferralInfo(Long userId);

    ReferralResponse applyReferralCode(Long userId, String code);

    void applyReferralOnRegister(Long newUserId, String code);
}
