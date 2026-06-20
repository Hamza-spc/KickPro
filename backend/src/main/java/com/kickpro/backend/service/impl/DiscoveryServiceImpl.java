package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.DiscoveryResponse;
import com.kickpro.backend.dto.response.MatchResponse;
import com.kickpro.backend.entity.Match;
import com.kickpro.backend.entity.MatchStatus;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.repository.MatchRepository;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.service.DiscoveryService;
import com.kickpro.backend.service.MatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DiscoveryServiceImpl implements DiscoveryService {

    private static final int TOP_PLAYERS_LIMIT = 5;
    private static final int UPCOMING_MATCHES_LIMIT = 5;

    private final PlayerProfileRepository playerProfileRepository;
    private final MatchRepository matchRepository;
    private final MatchService matchService;

    @Override
    @Transactional(readOnly = true)
    public DiscoveryResponse getDiscovery(String city) {
        if (city == null || city.isBlank()) {
            throw new BadRequestException("City is required");
        }

        String normalizedCity = city.trim();
        long playersNearby = playerProfileRepository.countByCityIgnoreCase(normalizedCity);
        long openMatches = matchRepository.countByStatusAndCityIgnoreCase(MatchStatus.OPEN, normalizedCity);

        List<Match> upcoming = matchRepository
                .findByStatusAndCityIgnoreCaseAndDateTimeAfterOrderByDateTimeAsc(
                        MatchStatus.OPEN, normalizedCity, LocalDateTime.now())
                .stream()
                .limit(UPCOMING_MATCHES_LIMIT)
                .toList();

        List<MatchResponse> upcomingResponses = upcoming.stream()
                .map(m -> matchService.getMatchById(m.getId()))
                .toList();

        List<PlayerProfile> topProfiles = playerProfileRepository
                .findByCityIgnoreCaseOrderByCredibilityScoreDesc(
                        normalizedCity, PageRequest.of(0, TOP_PLAYERS_LIMIT));

        List<DiscoveryResponse.DiscoveryPlayerSummary> topPlayers = topProfiles.stream()
                .map(p -> DiscoveryResponse.DiscoveryPlayerSummary.builder()
                        .playerId(p.getId())
                        .playerName(p.getFullName())
                        .profilePhotoUrl(p.getProfilePhotoUrl())
                        .city(p.getCity())
                        .credibilityScore(p.getCredibilityScore())
                        .build())
                .toList();

        return DiscoveryResponse.builder()
                .playersNearby(playersNearby)
                .openMatches(openMatches)
                .upcomingInCity(upcomingResponses)
                .topPlayers(topPlayers)
                .build();
    }
}
