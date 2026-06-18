package com.kickpro.backend.service.impl;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class CredibilityServiceImplTest {

    @Test
    void isPassingQuizScore_passesAtSeventyPercent() {
        assertTrue(CredibilityServiceImpl.isPassingQuizScore(7, 10));
        assertTrue(CredibilityServiceImpl.isPassingQuizScore(1, 1));
    }

    @Test
    void isPassingQuizScore_failsBelowSeventyPercent() {
        assertFalse(CredibilityServiceImpl.isPassingQuizScore(6, 10));
        assertFalse(CredibilityServiceImpl.isPassingQuizScore(0, 5));
    }
}
