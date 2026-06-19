package com.kickpro.backend.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.kickpro.backend.exception.BadRequestException;

public final class AiJsonHelper {

    private AiJsonHelper() {
    }

    public static String extractJsonPayload(String raw) {
        if (raw == null || raw.isBlank()) {
            throw new BadRequestException("AI returned an empty response");
        }
        String trimmed = raw.trim();
        if (trimmed.startsWith("```")) {
            int firstNewline = trimmed.indexOf('\n');
            int lastFence = trimmed.lastIndexOf("```");
            if (firstNewline >= 0 && lastFence > firstNewline) {
                trimmed = trimmed.substring(firstNewline + 1, lastFence).trim();
            }
        }
        return trimmed;
    }

    public static <T> T parseJson(ObjectMapper objectMapper, String raw, Class<T> type) {
        try {
            return objectMapper.readValue(extractJsonPayload(raw), type);
        } catch (JsonProcessingException ex) {
            throw new BadRequestException("AI returned invalid JSON: " + ex.getOriginalMessage());
        }
    }
}
