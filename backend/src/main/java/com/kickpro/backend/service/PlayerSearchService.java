package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.PlayerProfile;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface PlayerSearchService {

    Page<PlayerSearchResultResponse> searchPlayers(
            String name,
            Position position,
            String city,
            PreferredFoot preferredFoot,
            Integer minAge,
            Integer maxAge,
            Double minCredibility,
            Double maxCredibility,
            Integer minDribbling,
            Integer minShooting,
            Integer minPassing,
            Integer minSpeed,
            Integer minHeading,
            Integer minStamina,
            Integer minDrillScore,
            Boolean hasCertification,
            Pageable pageable
    );

    List<String> getDistinctCities();

    List<PlayerSearchResultResponse> toSearchResults(List<PlayerProfile> profiles);
}
