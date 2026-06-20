package com.kickpro.backend.service.impl;

import com.kickpro.backend.dto.response.PlayerComparisonResponse;
import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.exception.BadRequestException;
import com.kickpro.backend.exception.ResourceNotFoundException;
import com.kickpro.backend.repository.PlayerProfileRepository;
import com.kickpro.backend.service.PlayerComparisonService;
import com.kickpro.backend.service.PlayerSearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlayerComparisonServiceImpl implements PlayerComparisonService {

    private final PlayerProfileRepository playerProfileRepository;
    private final PlayerSearchService playerSearchService;

    @Override
    @Transactional(readOnly = true)
    public PlayerComparisonResponse comparePlayers(Long profileA, Long profileB) {
        if (profileA == null || profileB == null) {
            throw new BadRequestException("Both profileA and profileB are required");
        }
        if (profileA.equals(profileB)) {
            throw new BadRequestException("Select two different players to compare");
        }

        PlayerProfile playerA = playerProfileRepository.findById(profileA)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found: " + profileA));
        PlayerProfile playerB = playerProfileRepository.findById(profileB)
                .orElseThrow(() -> new ResourceNotFoundException("Player profile not found: " + profileB));

        List<PlayerSearchResultResponse> results = playerSearchService.toSearchResults(List.of(playerA, playerB));

        return PlayerComparisonResponse.builder()
                .profileA(results.get(0))
                .profileB(results.get(1))
                .build();
    }
}
