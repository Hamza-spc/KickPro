package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.PlayerSearchResultResponse;
import com.kickpro.backend.entity.Position;
import com.kickpro.backend.entity.PreferredFoot;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface PlayerSearchService {

    Page<PlayerSearchResultResponse> searchPlayers(
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
}
