package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class SquadDiscoverResponse {

    private Long id;
    private String name;
    private String city;
    private String captainName;
    private int memberCount;
    private String joinState;
}
