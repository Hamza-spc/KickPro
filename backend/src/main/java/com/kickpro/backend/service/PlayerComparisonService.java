package com.kickpro.backend.service;

import com.kickpro.backend.dto.response.PlayerComparisonResponse;

public interface PlayerComparisonService {

    PlayerComparisonResponse comparePlayers(Long profileA, Long profileB);
}
