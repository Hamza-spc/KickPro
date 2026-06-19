package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.Role;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class AdminUserResponse {

    private Long id;
    private String email;
    private Role role;
    private boolean enabled;
    private boolean agentVerified;
    private LocalDateTime createdAt;
}
