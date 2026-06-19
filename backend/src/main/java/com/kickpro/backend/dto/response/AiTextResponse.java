package com.kickpro.backend.dto.response;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class AiTextResponse {

    private String content;
}
