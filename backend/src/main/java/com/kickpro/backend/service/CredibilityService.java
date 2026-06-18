package com.kickpro.backend.service;

public interface CredibilityService {

    double recalculateForPlayer(Long playerProfileId);

    double recalculateForUser(Long userId);
}
