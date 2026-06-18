package com.kickpro.backend.dto.response;

import com.kickpro.backend.entity.Role;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AuthResponse {

    private String token;
    private Long userId;
    private String email;
    private Role role;
}
