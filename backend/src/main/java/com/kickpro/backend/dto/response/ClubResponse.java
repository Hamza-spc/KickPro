package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class ClubResponse {

    private Long id;
    private String name;
    private String city;
    private String description;
    private String logoUrl;
    private boolean verified;
    private Long ownerId;
    private String ownerName;
    private long memberCount;
    private LocalDateTime createdAt;
}
