package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ReferralResponse {

    private String code;
    private long referralCount;
    private LocalDateTime appliedAt;
}
