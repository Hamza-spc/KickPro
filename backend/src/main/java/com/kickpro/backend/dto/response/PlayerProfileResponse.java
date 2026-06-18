package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
public class PlayerProfileResponse {

    private Long id;
    private Long userId;
    private String fullName;
    private LocalDate dateOfBirth;
    private String city;
    private Position position;
    private PreferredFoot preferredFoot;
    private String bio;
    private Integer height;
    private Integer weight;
    private String profilePhotoUrl;
    private Double credibilityScore;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
