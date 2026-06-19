package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

import java.util.List;

@Getter
@Builder
public class ScoutAssistResponse {

    private List<Long> matchedPlayerIds;
    private String explanation;
}
