package com.kickpro.backend.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApplyReferralRequest {

    @NotBlank
    private String code;
}
