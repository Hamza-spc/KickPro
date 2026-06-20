package com.kickpro.backend.service.impl;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
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

    @Test
    void scoreTierLabel_mapsLowScoresToNeedsImprovement() {
        CredibilityServiceImpl service = new CredibilityServiceImpl(
                null, null, null, null, null, null, null);
        assertEquals("NEEDS SIGNIFICANT IMPROVEMENT (0-30)", service.scoreTierLabel(9));
        assertEquals("NEEDS SIGNIFICANT IMPROVEMENT (0-30)", service.scoreTierLabel(30));
        assertEquals("BELOW AVERAGE (31-50)", service.scoreTierLabel(45));
        assertEquals("AVERAGE (51-70)", service.scoreTierLabel(60));
        assertEquals("GOOD (71-85)", service.scoreTierLabel(80));
        assertEquals("EXCELLENT (86-100)", service.scoreTierLabel(95));
    }
}
