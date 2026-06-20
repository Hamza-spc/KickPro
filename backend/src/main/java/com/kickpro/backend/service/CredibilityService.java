package com.kickpro.backend.service;

import java.util.Map;

public interface CredibilityService {

    double recalculateForPlayer(Long playerProfileId);

    double recalculateForUser(Long userId);

    Map<String, Double> buildScoreBreakdown(Long playerProfileId);

    String scoreTierLabel(double score);
}
