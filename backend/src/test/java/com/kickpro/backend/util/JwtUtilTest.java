package com.kickpro.backend.util;

import com.kickpro.backend.entity.Role;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

@DisplayName("JwtUtil — token lifecycle")
class JwtUtilTest {

    private JwtUtil jwtUtil;

    @BeforeEach
    void setUp() {
        jwtUtil = new JwtUtil("test-secret-key-must-be-at-least-32-characters-long", 3_600_000L);
    }

    @Test
    @DisplayName("generated token validates and exposes claims")
    void generateToken_roundTrip() {
        String token = jwtUtil.generateToken(42L, "player@kickpro.dev", Role.PLAYER);

        assertTrue(jwtUtil.validateToken(token));
        assertEquals("player@kickpro.dev", jwtUtil.extractUsername(token));
        assertEquals(42L, jwtUtil.extractUserId(token));
        assertEquals(Role.PLAYER, jwtUtil.extractRole(token));
    }

    @Test
    @DisplayName("tampered token fails validation")
    void validateToken_rejectsTamperedToken() {
        String token = jwtUtil.generateToken(1L, "a@kickpro.dev", Role.ADMIN);
        String tampered = token.substring(0, token.length() - 4) + "xxxx";

        assertFalse(jwtUtil.validateToken(tampered));
    }

    @Test
    @DisplayName("garbage input fails validation")
    void validateToken_rejectsGarbage() {
        assertFalse(jwtUtil.validateToken("not-a-jwt"));
    }
}
