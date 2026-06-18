package com.kickpro.backend.service;

import com.kickpro.backend.dto.request.LoginRequest;
import com.kickpro.backend.dto.request.RegisterRequest;
import com.kickpro.backend.dto.response.AuthResponse;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);
}
