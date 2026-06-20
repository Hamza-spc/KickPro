package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PlayerComparisonResponse {

    private PlayerSearchResultResponse profileA;
    private PlayerSearchResultResponse profileB;
}
